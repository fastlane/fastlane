require 'cgi'
require 'pathname'

module Fastlane
  module Internal
    # Finds relative links in a Markdown file that point to a missing file or heading, and reference links with no definition.
    # Links with a scheme (https:, mailto:) and site-absolute paths (/actions/gym/, used by docs.fastlane.tools) are not checked.
    class MarkdownLinks
      attr_accessor :path

      def initialize(path:)
        @path = path
      end

      def errors
        lines = self.class.prose_lines(path)
        definitions = lines.flat_map { |line, _| line.scan(/^\s{0,3}\[([^\]]+)\]:\s*\S/).flatten.map(&:downcase) }

        lines.flat_map do |line, number|
          text = line.gsub(/`[^`]*`/, '')
          location = "'#{path}:#{number}'"
          line_errors = targets(text).map { |target| (reason = target_error(target)) && "Broken link #{target} in #{location}: #{reason}" }.compact
          text.scan(/\[([^\]]*)\]\[([^\]]*)\]/).each do |label_text, label|
            name = label.empty? ? label_text : label
            line_errors << "Undefined reference [#{name}] in #{location}" unless definitions.include?(name.downcase)
          end
          line_errors
        end
      end

      # The anchors GitHub generates for a file's headings (Markdown and HTML), plus explicit id and name attributes
      def self.anchors(file)
        @anchors ||= {}
        @anchors[file] ||= begin
          counts = Hash.new(0)
          previous = nil
          html_heading = nil
          prose_lines(file).each_with_object([]) do |(line, _), anchors|
            heading = line[/\A {0,3}\#{1,6}\s+(.*?)\s*#*\s*\z/, 1]
            heading = previous if heading.nil? && previous && line =~ /\A {0,3}(=+|-+)\s*\z/ && previous !~ /\A\s*([-*+|>]|\d+\.)\s/
            html_heading = +'' if heading.nil? && html_heading.nil? && line =~ /<h[1-6][\s>]/i
            if html_heading
              html_heading << line << "\n"
              heading = html_heading[%r{<h[1-6][^>]*>(.*?)</h[1-6]>}im, 1]
              html_heading = nil if heading
            end
            if heading
              slug = slug(heading)
              anchors << (counts[slug].zero? ? slug : "#{slug}-#{counts[slug]}")
              counts[slug] += 1
            end
            line.scan(/<[a-z][^>]*\s(?:id|name)=["']([^"']+)["']/i) { |(anchor)| anchors << anchor.downcase }
            previous = line.strip.empty? ? nil : line.strip
          end
        end
      end

      # GitHub's heading slug: the rendered text, lowercased, without punctuation, spaces as hyphens
      def self.slug(heading)
        # Links and images keep their text, autolinks their URL; other HTML tags go
        text = heading.gsub(/!?\[([^\]]*)\]\([^)]*\)/, '\1').gsub(%r{<(https?://[^>]+)>}, '\1').gsub(/<[^>]+>/, '')
        # Emphasis markers go, but not underscores inside words or code
        text = text.split(/(`[^`]*`)/).map { |part| part.start_with?('`') ? part.delete('`') : part.delete('*').gsub(/(?<![[:alnum:]])_+|_+(?![[:alnum:]])/, '') }.join
        text.downcase.gsub(/[^\p{L}\p{M}\p{N}_\- ]/, '').tr(' ', '-')
      end

      # [line, line number] pairs outside YAML front matter and fenced code blocks
      def self.prose_lines(file)
        fence = nil
        front_matter = false
        File.readlines(file, mode: 'rb:BOM|UTF-8').each_with_index.with_object([]) do |(line, index), lines|
          marker = line[/\A {0,3}(`{3,}|~{3,})/, 1]
          if index.zero? && line.chomp == '---'
            front_matter = true
          elsif front_matter
            front_matter = false if line.chomp == '---'
          elsif fence
            fence = nil if marker && marker[0] == fence[0] && marker.length >= fence.length
          elsif marker
            fence = marker
          else
            lines << [line.chomp, index + 1]
          end
        end
      end

      private

      def targets(text)
        text.scan(/!?\[[^\]]*\]\(\s*<?([^)\s>]+)>?(?:\s+"[^"]*")?\s*\)/).flatten +
          text.scan(/^\s{0,3}\[[^\]]+\]:\s*<?([^\s>]+)/).flatten +
          text.scan(/<(?:a|img)\s[^>]*\b(?:href|src)="([^"]+)"/i).flatten
      end

      def target_error(target)
        return nil if target =~ %r{\A([a-z][a-z0-9+.-]*:|//|/)}i

        file, anchor = target.split('#', 2)
        file = CGI.unescape(file.sub(/\?.*\z/, ''))
        resolved = file.empty? ? path : Pathname.new(File.join(File.dirname(path), file)).cleanpath.to_s
        return "no file #{resolved}" unless File.exist?(resolved)
        return nil if anchor.nil? || anchor.empty? || !resolved.end_with?('.md')

        "no heading ##{anchor} in #{resolved}" unless self.class.anchors(resolved).include?(CGI.unescape(anchor).downcase)
      end
    end
  end
end
