require "fastlane_core/ui/ui"

# Reference for the MP4/QuickTime container (video atoms/boxes structure): ISO/IEC 14496-12:2022 (base media file format) - defines atoms like moov/trak/tkhd
# - https://observablehq.com/@benjamintoofer/iso-base-media-file-format
# - https://developer.apple.com/documentation/quicktime-file-format
module FastlaneCore
  module VideoUtils
    # Pure Ruby MP4/QuickTime MOV container header parser, reading tkhd to get width/height.
    # Note: This reads container atoms/boxes only; it does NOT parse the video codec bitstream.
    # Works regardless of codec as long as standard container headers exist.
    # Input: path (String) to a local MP4/MOV file.
    # Output: [width, height] (Array<Integer>) normalized to portrait (w <= h), or nil on failure.
    def self.read_video_resolution(path)
      File.open(path, "rb") do |f|
        file_size = f.size
        while f.pos < file_size
          size, type = read_atom_header(f)
          break unless size && type
          return nil if size < 8
          content = size - 8
          if type == "moov"
            moov_end = f.pos + content
            resolution = extract_resolution_from_moov(f, moov_end)
            return resolution if resolution
          else
            skip(f, content)
          end
        end
      end
      nil
    rescue => e
      FastlaneCore::UI.verbose("Failed to parse resolution for '#{path}': #{e.class} - #{e.message}")
      nil
    end

    # Pure Ruby MP4/QuickTime MOV container header parser reading mvhd to get duration in seconds.
    # Note: Uses movie header (mvhd) time scale/duration, not per-track edit lists; adequate for gating.
    # Input: path (String) to a local MP4/MOV file.
    # Output: duration in seconds (Float), or nil on failure.
    def self.read_video_duration_seconds(path)
      File.open(path, "rb") do |f|
        file_size = f.size
        while f.pos < file_size
          size, type = read_atom_header(f)
          break unless size && type
          return nil if size < 8
          content = size - 8
          if type == "moov"
            moov_end = f.pos + content
            duration = extract_duration_from_moov(f, moov_end)
            return duration if duration
          else
            skip(f, content)
          end
        end
      end
      nil
    rescue => e
      FastlaneCore::UI.verbose("Failed to parse duration for '#{path}': #{e.class} - #{e.message}")
      nil
    end

    # Reads the moov box and returns [w, h] if found in any trak/tkhd, else nil.
    # Input: io (IO) positioned at moov contents; moov_end (Integer) absolute end offset.
    # Output: [width, height] or nil.
    def self.extract_resolution_from_moov(io, moov_end)
      while io.pos < moov_end
        atom_size, atom_type = read_atom_header(io)
        break unless atom_size && atom_type
        return nil if atom_size < 8
        if atom_type == "trak"
          trak_end = io.pos + (atom_size - 8)
          resolution = extract_resolution_from_trak(io, trak_end)
          return resolution if resolution
          io.seek(trak_end, IO::SEEK_SET)
        else
          skip(io, atom_size - 8)
        end
      end
      nil
    end

    # Reads the moov box and returns duration in seconds if mvhd is found, else nil.
    # Input: io (IO) positioned at moov contents; moov_end (Integer) absolute end offset.
    # Output: Float seconds or nil.
    def self.extract_duration_from_moov(io, moov_end)
      while io.pos < moov_end
        atom_size, atom_type = read_atom_header(io)
        break unless atom_size && atom_type
        return nil if atom_size < 8
        if atom_type == "mvhd"
          return parse_mvhd(io)
        else
          skip(io, atom_size - 8)
        end
      end
      nil
    end

    # Reads a single trak box to locate tkhd and extract resolution.
    # Input: io (IO) positioned at trak contents; trak_end (Integer) absolute end offset.
    # Output: [width, height] or nil.
    def self.extract_resolution_from_trak(io, trak_end)
      while io.pos < trak_end
        trak_size, trak_type = read_atom_header(io)
        break unless trak_size && trak_type
        return nil if trak_size < 8
        if trak_type == "tkhd"
          return parse_tkhd(io)
        else
          skip(io, trak_size - 8)
        end
      end
      nil
    end

    # Parses mvhd box fields to read duration.
    # Input: io (IO) positioned at the start of mvhd payload after its header.
    # Output: Float seconds or nil.
    def self.parse_mvhd(io)
      version_flags = io.read(4)
      return nil unless version_flags && version_flags.length == 4
      version = version_flags.getbyte(0)
      if version == 1
        skip(io, 8) # creation_time (u64)
        skip(io, 8) # modification_time (u64)
        timescale = read_u32(io)
        duration = read_u64(io) # u64
      else
        skip(io, 4) # creation_time (u32)
        skip(io, 4) # modification_time (u32)
        timescale = read_u32(io)
        duration = read_u32(io) # u32
      end
      return nil unless timescale && timescale > 0
      return nil unless duration
      duration.to_f / timescale
    end

    # Parses tkhd box fields to read fixed-point width and height (16.16).
    # Input: io (IO) positioned at the start of tkhd payload after its header.
    # Output: [width, height] or nil.
    def self.parse_tkhd(io)
      video_flags = io.read(4)
      return nil unless video_flags && video_flags.length == 4
      version = video_flags.getbyte(0)
      if version == 1
        skip(io, 8 * 2) # creation, modification (u64)
        skip(io, 4)     # track id (u32)
        skip(io, 4)     # reserved
        skip(io, 8)     # duration (u64)
      else
        skip(io, 4 * 3) # creation, modification, track id (u32)
        skip(io, 4)     # reserved
        skip(io, 4)     # duration (u32)
      end
      skip(io, 8)       # reserved
      skip(io, 2)       # layer (u16)
      skip(io, 2)       # alt group (u16)
      skip(io, 2)       # volume (u16)
      skip(io, 2)       # reserved
      skip(io, 36)      # matrix
      # width/height (fixed point 16.16)
      width_fixed = read_u32(io)
      height_fixed = read_u32(io)
      return nil unless width_fixed && height_fixed
      width = (width_fixed >> 16)
      height = (height_fixed >> 16)
      [width, height]
    end

    # Read a big-endian 32-bit unsigned integer; returns Integer or nil if insufficient data.
    def self.read_u32(io)
      bytes = io.read(4)
      return nil unless bytes && bytes.length == 4
      bytes.unpack1("N") # 32-bit unsigned, network (big-endian) byte order
    end

    # Read a big-endian 64-bit unsigned integer; returns Integer or nil if insufficient data.
    def self.read_u64(io)
      bytes = io.read(8)
      return nil unless bytes && bytes.length == 8
      bytes.unpack1("Q>") # 64-bit unsigned, big-endian
    end

    # Read an atom/box header: returns [size(Integer), type(String)] or nil.
    def self.read_atom_header(io)
      size = read_u32(io)
      return nil unless size
      type = io.read(4)
      return nil unless type && type.length == 4
      [size, type]
    end

    # Advance the IO cursor by n bytes.
    def self.skip(io, n)
      io.seek(n, IO::SEEK_CUR)
    end

    private_class_method :extract_resolution_from_moov, :extract_duration_from_moov, :extract_resolution_from_trak, :parse_tkhd, :parse_mvhd, :read_u32, :read_u64, :read_atom_header, :skip
  end
end
