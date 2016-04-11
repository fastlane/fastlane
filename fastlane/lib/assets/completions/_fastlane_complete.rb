#!/usr/bin/env ruby

fastfile = File.join(Dir.pwd, "Fastfile")
fastfile = File.join(Dir.pwd, "fastlane", "Fastfile") unless File.exist?(fastfile)
fastfile = File.join(Dir.pwd, ".fastlane", "Fastfile") unless File.exist?(fastfile)

exit unless File.exist?(fastfile)

class MyBinding
  attr_reader :lanes
  attr_accessor :loader
  attr_reader :fastfiles

  def initialize
    @lanes = []
    @fastfiles = []
  end

  def the_binding
    return binding
  end

  def method_missing(method_name, *arguments, &block)
    if method_name.to_s == "platform"
      yield
    elsif method_name.to_s == "lane"
      @lanes << arguments[0]
    elsif method_name.to_s == "import"
      @loader.load_fastfile(arguments[0])
      # FIXME
      # elsif method_name.to_s == "import_from_git"
      #  @loader.load_fastfile(arguments[0])
    end
  end
end

class Loader
  attr_reader :mb

  def initialize
    @mb = MyBinding.new
    @mb.loader = self
  end

  def load_fastfile(fastfile)
    fromfile = @mb.fastfiles[-1] if @mb.fastfiles.count > 0
    path = fastfile
    unless fromfile.nil?
      unless path.start_with?("/")
        path = File.expand_path File.join(File.dirname(fromfile), fastfile)
      end
    end
    @mb.fastfiles.push path
    content = File.read(path)
    # rubocop:disable Lint/Eval
    eval(content, @mb.the_binding) # using eval is ok for this case
    # rubocop:enable Lint/Eval
    @mb.fastfiles.pop
  end
end

# consider checking for COMP_SHELL to escape output differently
m = ENV['COMP_LINE'].match(/fastlane (.*)/)
line = m[1] if m

L = Loader.new
L.load_fastfile(fastfile)
lanes = L.mb.lanes
puts lanes.select { |lane| lane.match(/^#{line}/) }
