module Fastlane
  module Helper
    class PodspecHelper
      attr_accessor :path
      attr_accessor :podspec_content
      attr_accessor :version_regex
      attr_accessor :version_match
      attr_accessor :version_value

      def initialize(path = nil, require_variable_prefix = true)
        version_var_name = 'version'
        variable_prefix = require_variable_prefix ? /\w\./ : //
        @version_regex = /^(?<begin>[^#]*#{variable_prefix}#{version_var_name}\s*=\s*['"])(?<value>(?<major>[0-9]+)(\.(?<minor>[0-9]+))?(\.(?<patch>[0-9]+))?(?<appendix>(\.[0-9]+)*)?)(?<end>['"])/i

        return unless (path || '').length > 0
        UI.user_error!("Could not find podspec file at path '#{path}'") unless File.exist?(path)

        @path = File.expand_path(path)
        podspec_content = File.read(path)

        parse(podspec_content)
      end

      def parse(podspec_content)
        @podspec_content = podspec_content
        @version_match = @version_regex.match(@podspec_content)
        UI.user_error!("Could not find version in podspec content '#{@podspec_content}'") if @version_match.nil?
        @version_value = @version_match[:value]
      end

      def bump_version(bump_type)
        UI.user_error!("Do not support bump of 'appendix', please use `update_version_appendix(appendix)` instead") if bump_type == 'appendix'

        major = version_match[:major].to_i
        minor = version_match[:minor].to_i || 0
        patch = version_match[:patch].to_i || 0

        case bump_type
        when 'patch'
          patch += 1
        when 'minor'
          minor += 1
          patch = 0
        when 'major'
          major += 1
          minor = 0
          patch = 0
        end

        @version_value = "#{major}.#{minor}.#{patch}"
      end

      def update_version_appendix(appendix = nil)
        new_appendix = appendix || @version_value[:appendix]
        return if new_appendix.nil?

        new_appendix = new_appendix.sub(".", "") if new_appendix.start_with?(".")
        major = version_match[:major].to_i
        minor = version_match[:minor].to_i || 0
        patch = version_match[:patch].to_i || 0

        @version_value = "#{major}.#{minor}.#{patch}.#{new_appendix}"
      end

      def update_podspec(version = nil)
        new_version = version || @version_value
        updated_podspec_content = @podspec_content.gsub(@version_regex, "#{@version_match[:begin]}#{new_version}#{@version_match[:end]}")

        File.open(@path, "w") { |file| file.puts(updated_podspec_content) } unless Helper.test?

        updated_podspec_content
      end
    end
  end
end
