module FastlaneCore
  module Xcode
    # Flattens an `.xcconfig` file into a Hash the same way the Xcodeproj gem does when it
    # resolves build settings: `#include`d files are merged first, in order, and the file's
    # own assignments win over them.
    module Xcconfig
      KEY_VALUE_PATTERN = /
        (
          [^=\[]+      # the setting name
          (?:\[[^\]]*(?:=[^\]]*)?\])*   # optional conditional subscripts, e.g. [sdk=iphoneos*]
        )
        \s*=(.*)
      /x
      INHERITED = ['$(inherited)', '${inherited}'].freeze
      INHERITED_REGEXP = Regexp.union(INHERITED)

      def self.load(path, visited = {})
        path = File.expand_path(path.to_s)
        return {} if visited[path] || !File.readable?(path)
        visited[path] = true

        attributes = {}
        includes = []
        File.read(path).split("\n").each do |line|
          uncommented = line.partition('//').first
          if (include = uncommented[/#include\??\s*"(.+)"/, 1])
            include = "#{include}.xcconfig" unless File.extname(include) == '.xcconfig'
            includes << File.expand_path(include, File.dirname(path))
          elsif (match = uncommented.match(KEY_VALUE_PATTERN))
            key = match[1].strip
            value = match[2].strip
            value = value.gsub(INHERITED_REGEXP) { |keyword| attributes.fetch(key, keyword) }
            attributes[key] = value
          end
        end
        attributes.reject! { |_, value| INHERITED.include?(value.strip) }

        includes.map { |include| load(include, visited) }.inject({}, &:merge).merge(attributes)
      end
    end
  end
end
