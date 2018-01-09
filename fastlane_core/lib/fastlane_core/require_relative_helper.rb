# Allows nice relative directory require_relative
# like `require_relative from_fastlane_core/'helper'`
base_fastlane_dir = File.expand_path("../../../", File.dirname(__FILE__))
tool_dirs = Dir["#{base_fastlane_dir}/**/lib/*.rb"]
tool_dirs.map { |t| File.basename(t, ".rb") }.each do |tool|
  define_method("from_#{tool}".to_sym) do
    source = Pathname.new(File.dirname(caller.first.split(":").first))
    destination = Pathname.new(File.join(base_fastlane_dir, tool, "lib", tool))
    destination.relative_path_from(source)
  end
end
