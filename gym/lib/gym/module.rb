require 'fastlane_core/helper'
require 'fastlane/boolean'
require_relative 'detect_values'

module Gym
  class << self
    attr_accessor :config

    attr_accessor :project

    attr_accessor :cache

    def config=(value)
      @config = value
      DetectValues.set_additional_default_values
      @cache = {}
    end

    def gymfile_name
      "Gymfile"
    end

    def init_libs
      # Import all the fixes
      require 'gym/xcodebuild_fixes/generic_archive_fix'
    end

    def building_for_ipa?
      return !building_for_pkg?
    end

    def building_for_pkg?
      return building_for_mac?
    end

    def building_for_ios?
      return true if building_for_non_mac_destination?

      if Gym.project.mac?
        # Can be building for iOS if mac project and catalyst or multiplatform and set to iOS
        return building_mac_catalyst_for_ios? || building_multiplatform_for_ios?
      else
        # Can be iOS project and build for mac if catalyst
        return false if building_mac_catalyst_for_mac?

        # Can be iOS project if iOS, tvOS, watchOS, or visionOS
        return Gym.project.ios? || Gym.project.tvos? || Gym.project.watchos? || Gym.project.visionos?
      end
    end

    def building_for_mac?
      return false if building_for_non_mac_destination?

      if Gym.project.supports_mac_catalyst?
        # Can be a mac project and not build mac if catalyst
        return building_mac_catalyst_for_mac?
      else
        return (!Gym.project.multiplatform? && Gym.project.mac?) || building_multiplatform_for_mac?
      end
    end

    # Whether the configuration already rules out a macOS build: the destination names
    # an iOS, tvOS, watchOS or visionOS platform, and neither `sdk` nor `catalyst_platform`
    # asks for macOS. The platform checks answer from this before reading the project's
    # build settings, which may be disallowed. Anything else, including a destination
    # without a platform, falls through to them
    def building_for_non_mac_destination?
      return false if Gym.config[:sdk].to_s.start_with?("macosx") || Gym.config[:catalyst_platform] == "macos"

      destination_platform.match?(/\A(iOS|tvOS|watchOS|visionOS|xrOS)( Simulator)?\z/i)
    end

    # The platform named by `destination`, e.g. "iOS" for "generic/platform=iOS"
    def destination_platform
      Gym.config[:destination].to_s[/platform=([^,]+)/, 1].to_s.strip
    end

    def building_mac_catalyst_for_ios?
      # If catalyst_platform is explicitly set, use it
      # If catalyst_platform is not set, use SDK to determine
      # Mac Catalyst apps with iOS SDK build for iOS (IPA), not macOS
      for_ios = if Gym.config[:catalyst_platform]
                  Gym.config[:catalyst_platform] == "ios"
                else
                  Gym.config[:sdk] == "iphoneos" || Gym.config[:sdk] == "iphonesimulator"
                end

      # Only read the project's build settings when they can change the answer
      for_ios && Gym.project.supports_mac_catalyst?
    end

    def building_mac_catalyst_for_mac?
      # If catalyst_platform is explicitly set, use it
      # If catalyst_platform is not set, use SDK to determine
      # Mac Catalyst apps with SDK macosx build for Mac (PKG), otherwise for iOS (IPA)
      for_mac = if Gym.config[:catalyst_platform]
                  Gym.config[:catalyst_platform] == "macos"
                else
                  Gym.config[:sdk] == "macosx"
                end

      # Only read the project's build settings when they can change the answer
      for_mac && Gym.project.supports_mac_catalyst?
    end

    def building_multiplatform_for_ios?
      Gym.project.multiplatform? && Gym.project.ios? && (Gym.config[:sdk] == "iphoneos" || Gym.config[:sdk] == "iphonesimulator")
    end

    def building_multiplatform_for_mac?
      Gym.project.multiplatform? && Gym.project.mac? && Gym.config[:sdk] == "macosx"
    end

    def export_destination_upload?
      config_path = Gym.cache[:config_path]
      return false if config_path.nil?

      result = CFPropertyList.native_types(CFPropertyList::List.new(file: config_path).value)
      return result["destination"] == "upload"
    end
  end

  Helper = FastlaneCore::Helper # you gotta love Ruby: Helper.* should use the Helper class contained in FastlaneCore
  UI = FastlaneCore::UI
  Boolean = Fastlane::Boolean
  ROOT = Pathname.new(File.expand_path('../../..', __FILE__))
  DESCRIPTION = "Building your iOS apps has never been easier"

  Gym.init_libs
end
