def calling_file(depth: 2)
  # The right file is either 2 when called in from_base or 3 when called in from_tool
  caller_locations(2, 3).find{ |c| !c.absolute_path.end_with?('require_relative_helper.rb') }.absolute_path
end

FASTLANE_BASE_DIR = File.expand_path("../../../", File.dirname(__FILE__))

def from_base(to_file: nil)
  to_file ||= calling_file
  source = Pathname.new(File.dirname(to_file))
  destination = Pathname.new(FASTLANE_BASE_DIR)
  destination.relative_path_from(source)
end

# Allows nice relative directory require_relative
# like `require_relative from_fastlane_core/'helper'`
tool_dirs_ = Dir["#{FASTLANE_BASE_DIR}/**/lib/*.rb"]
tool_dirs_.map { |t| File.basename(t, ".rb") }.each do |tool|
  define_method("from_#{tool}".to_sym) do |**kwargs|
    from_base(**kwargs) / tool / "lib" / tool
  end
end
