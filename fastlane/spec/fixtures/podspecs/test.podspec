Pod::Spec.new do |s|
  s.name         = "SpecName"
  s.header_dir   = "SuchHeader"
  s.version      = "1.5.1"
  s.summary      = "With just a few lines of code, your app can add fastlane support."

  s.description  = <<-DESC
                   Much bla
                   DESC

  s.homepage          = "https://github.com/fastlane/fastlane"
  s.license           = { type: 'MIT', file: 'LICENSE.txt' }
  s.authors           = ["Felix Krause"]
  s.social_media_url  = "https://twitter.com/FastlaneTools"

  s.source            = { git: "https://github.com/fastlane/fastlane.git", tag: s.version }
  s.platform          = :ios, 7.0
  s.source_files      = "*.{h,m}"
  s.frameworks        = "UIKit"
  s.weak_framework    = "WebKit"
  s.exclude_files     = "Demos"
  s.resource_bundles  = { 'SomeResources' => ['yeah.xcassets/*.imageset/*.png', 'yeah.xcassets'] }
  s.requires_arc      = true
end
