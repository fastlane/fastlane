module Gym
  class Xcode
    class << self
      # Path to the Xcode installation we're using
      def xcode_path
        @path ||= `xcode-select --print-path`.strip
      end

      # Version of Xcode, e.g. 7.0
      def xcode_version
        @version ||= parse_version
      end

      # Below Xcode 7 (which offers a new nice API to sign the app)
      def pre_7?
        v = xcode_version
        is_pre = v.split('.')[0].to_i < 7
        is_pre
      end

      private

      def parse_version
        output = `DEVELOPER_DIR='' "#{xcode_path}/usr/bin/xcodebuild" -version`
        return '0.0' if output.nil?
        output.split("\n").first.split(' ')[1]
      end
    end
  end
end
