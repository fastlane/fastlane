Pod::Spec.new do |s|
  s.name         = "1PasswordExtension"
  s.header_dir   = "OnePasswordExtension"
  s.Version      = "1.5.1"
  s.summary      = "With just a few lines of code, your app can add 1Password support."

  s.description  = <<-DESC
                   With just a few lines of code, your app can add 1Password support, enabling your users to:
                  - Access their 1Password Logins to automatically fill your login page.
                  - Use the Strong Password Generator to create unique passwords during registration, and save the new Login within 1Password.
                  - Quickly fill 1Password Logins directly into web views.
                   Empowering your users to use strong, unique passwords has never been easier.
                   DESC

  s.homepage          = "https://github.com/AgileBits/onepassword-app-extension"
  s.license           = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.authors           = [ "Dave Teare", "Michael Fey", "Rad Azzouz", "Roustem Karimov" ]
  s.social_media_url  = "https://twitter.com/1Password"

  s.source            = { :git => "https://github.com/AgileBits/onepassword-app-extension.git", :tag => s.version }
  s.platform          = :ios, 7.0
  s.source_files      = "*.{h,m}"
  s.frameworks        = "UIKit"
  s.weak_framework    = "WebKit"
  s.exclude_files     = "Demos"
  s.resource_bundles  = { 'OnePasswordExtensionResources' => ['1Password.xcassets/*.imageset/*.png', '1Password.xcassets'] }
  s.requires_arc      = true
end