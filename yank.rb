# install dependency first

tools_to_remove = {
  pem: ["1.5.1", "1.5.0"],
  sigh: ["1.13.1", "1.13.0"],
  screengrab: ["0.6.1", "0.6.0"],
  snapshot: ["1.18.1", "1.18.0"],
  produce: ["1.5.1", "1.5.0"],
  frameit: ["3.1.1", "3.1.0"],
  credentials_manager: ["0.16.3", "0.16.2", "0.16.1", "0.16.0"],
  cert: ["1.5.1", "1.5.0"],
  fastlane_core: ["0.60.1", "0.60.0"],
  gym: ["1.14.0"],
  deliver: ["1.17.0"],
  supply: ["0.9.0"],
  match: ["0.12.0"],
  scan: ["0.15.0"]
}

tools_to_remove.each do |gem_name, versions|
  versions.each do |version|
    puts "Removing gem #{gem_name} (#{version})"
    command = "gem yank '#{gem_name}' -v '#{version}'"
    puts "> #{command}"
    puts `#{command}`
  end
end
