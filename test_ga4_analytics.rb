#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script for GA4 Analytics Implementation
# Usage from repo root: ruby test_ga4_analytics.rb
#
# This script sends a real test event to the GA4 endpoint.
# You can monitor events in Google Analytics 4 Real-Time reports or DebugView.

require_relative 'fastlane_core/lib/fastlane_core/analytics/analytics_ingester_client'
require_relative 'fastlane_core/lib/fastlane_core/analytics/analytics_event_builder'
require_relative 'fastlane_core/lib/fastlane_core/analytics/analytics_session'
require_relative 'fastlane_core/lib/fastlane_core/analytics/action_launch_context'
require_relative 'fastlane_core/lib/fastlane_core/helper'
require 'securerandom'

# Temporarily disable opt-out for testing
ENV.delete('FASTLANE_OPT_OUT_USAGE')

puts "\n" + "=" * 80
puts "GA4 Analytics Test Script"
puts "=" * 80
puts "\nThis script sends a real test event to GA4 using the client-side endpoint."
puts "\nConfiguration:"
puts "  - Tracking ID: G-94HQ3VVP0X"
puts "  - Endpoint: https://www.google-analytics.com/g/collect (client-side, no API secret needed)"
puts "  - Platform: #{RUBY_PLATFORM}"
puts "  - Ruby Version: #{RUBY_VERSION}"

# Try to get Xcode version
xcode_ver = nil
begin
  if FastlaneCore::Helper.mac?
    xcode_ver = FastlaneCore::Helper.xcode_version
    puts "  - Xcode Version: #{xcode_ver || 'N/A'}"
  else
    puts "  - Xcode Version: N/A (not on macOS)"
  end
rescue
  puts "  - Xcode Version: N/A (error detecting)"
end

# Determine platform
platform = case RUBY_PLATFORM
           when /darwin/ then :ios
           when /linux/ then :android
           else :unknown
           end

puts "\nEvent will capture:"
puts "  - ruby_version: #{RUBY_VERSION}"
puts "  - platform: #{platform}"
puts "  - client_language: ruby"
puts "  - xcode_version: #{xcode_ver}" if xcode_ver

puts "\n" + "-" * 80
puts "Press Enter to send test event, or Ctrl+C to cancel..."
gets

# Create analytics session
puts "\nInitializing analytics session..."
session = FastlaneCore::AnalyticsSession.new

# Create launch context
puts "Creating launch context..."
launch_context = FastlaneCore::ActionLaunchContext.new(
  action_name: "test_action",
  p_hash: SecureRandom.uuid,
  platform: platform,
  fastlane_client_language: :ruby
)

# Send event
puts "Sending event to GA4..."
session.action_launched(launch_context: launch_context)

# Wait for thread to complete
puts "Waiting for request to complete..."
sleep(2)
session.finalize_session

puts "\n" + "=" * 80
puts "✅ Event sent successfully!"
puts "\nTo verify in Google Analytics 4:"
puts "1. Go to https://analytics.google.com/"
puts "2. Select the property with ID: G-94HQ3VVP0X"
puts "3. Navigate to: Reports > Realtime (or Admin > DebugView)"
puts "4. Look for events in the last 30 minutes:"
puts "   - Event name: launch"
puts "   - Event parameters:"
puts "     • event_category: fastlane Client Language - ruby"
puts "     • ruby_version: #{RUBY_VERSION}"
puts "     • platform: #{platform}"
puts "     • client_language: ruby"
puts "     • xcode_version: #{xcode_ver}" if xcode_ver

puts "\nNote: The endpoint now uses /g/collect (client-side) which:"
puts "  - Does NOT require an API secret (safe for public code)"
puts "  - Uses URL-encoded parameters (like gtag.js)"
puts "  - Sends with _dbg=1 for easier debugging in GA4 DebugView"

puts "\n" + "=" * 80 + "\n"
