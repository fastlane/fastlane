require 'trainer'

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

# xcresulttool writes database.sqlite3 into a bundle the first time it reads it,
# so parallel workers reading the same checked-in bundle race. Read a copy instead.
def with_xcresult_fixture_copy(name)
  Dir.mktmpdir("fl_spec_xcresult") do |dir|
    FileUtils.cp_r(File.join(__dir__, "fixtures", name), dir)
    yield(File.join(dir, name))
  end
end
