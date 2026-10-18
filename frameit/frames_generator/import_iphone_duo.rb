require 'fileutils'
require 'json'
require 'open3'
require 'optparse'
require 'tmpdir'

module Frameit
  # Imports locally downloaded Apple artwork without redistributing it.
  class DuoFrameImporter
    SCREENS = {
      "Outer" => { source: "Outer Closed Portrait", size: [1398, 2034], canvas: [1574, 2194], origin: [88, 80] },
      "Inner" => { source: "Inner Open Portrait", size: [2007, 2853], canvas: [2247, 3093], origin: [120, 120] }
    }.freeze
    COLORS = ["Night Sky", "Star White"].freeze

    def self.run_magick(*)
      output, status = Open3.capture2e("magick", *)
      raise "ImageMagick failed: #{output}" unless status.success?
      output.strip
    end

    def self.import(source, destination)
      png_directory = File.directory?(File.join(source, "PNG")) ? File.join(source, "PNG") : source
      offsets_path = File.join(destination, "offsets.json")
      offsets = File.exist?(offsets_path) ? JSON.parse(File.read(offsets_path)) : {}
      offsets["portrait"] ||= {}

      # Validate every input before writing into the frame cache.
      SCREENS.each_value do |screen|
        COLORS.each do |color|
          path = File.join(png_directory, "iPhone Duo - #{color} - #{screen[:source]}.png")
          dimensions = run_magick("identify", "-format", "%w %h", path).split.map(&:to_i)
          raise "Unexpected dimensions for #{path}: #{dimensions}" unless dimensions == screen[:canvas]
        end
      end

      FileUtils.mkdir_p(destination)
      Dir.mktmpdir("frameit-duo") do |staging|
        SCREENS.each do |name, screen|
          width, height = screen[:size]
          x, y = screen[:origin]
          mask_name = "Apple iPhone Duo #{name} Screen Mask.png"
          COLORS.each do |color|
            original = File.join(png_directory, "iPhone Duo - #{color} - #{screen[:source]}.png")
            FileUtils.cp(original, File.join(staging, "Apple iPhone Duo #{name} #{color}.png"))
          end
          original = File.join(png_directory, "iPhone Duo - #{COLORS.first} - #{screen[:source]}.png")
          # Fill the exterior transparency before inverting, leaving only the
          # enclosed display opening white. Camera and asymmetric corners stay black.
          run_magick(original, "-alpha", "extract", "-alpha", "off", "-threshold", "0",
                     "-fill", "white", "-draw", "color 0,0 floodfill", "-channel", "RGB", "-negate", "+channel", "-alpha", "off",
                     "-crop", "#{width}x#{height}+#{x}+#{y}", "+repage", File.join(staging, mask_name))
          offsets["portrait"]["iPhone Duo #{name}"] = {
            "offset" => "+#{x}+#{y}", "width" => width, "mask" => mask_name
          }
        end
        Dir.glob(File.join(staging, "*.png")).each { |path| FileUtils.cp(path, destination) }
      end
      File.write(offsets_path, JSON.pretty_generate(offsets) + "\n")
    end
  end
end

if $PROGRAM_NAME == __FILE__
  options = {}
  parser = OptionParser.new do |opts|
    opts.banner = "Usage: ruby import_iphone_duo.rb --source APPLE_BEZELS --output FRAME_CACHE"
    opts.on("--source PATH", "Extracted Apple Duo artwork directory (or its PNG folder)") { |value| options[:source] = value }
    opts.on("--output PATH", "Existing frameit frame cache directory") { |value| options[:output] = value }
  end
  parser.parse!
  abort(parser.to_s) unless options[:source] && options[:output]
  Frameit::DuoFrameImporter.import(File.expand_path(options[:source]), File.expand_path(options[:output]))
  puts("Installed iPhone Duo Outer and Inner frames in #{options[:output]}")
end
