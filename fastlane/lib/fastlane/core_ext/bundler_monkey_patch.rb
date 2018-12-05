# https://github.com/bundler/bundler/issues/4368
#
# There is an issue with RubyGems 2.6.2 where it attempts to call Bundler::SpecSet#size, which doesn't exist.
# If a gem is not installed, a `Gem::Specification.find_by_name` call will trigger this problem.
if Object.const_defined?(:Bundler) &&
   Bundler.const_defined?(:SpecSet) &&
   Bundler::SpecSet.instance_methods.include?(:length) &&
   !Bundler::SpecSet.instance_methods.include?(:size)
  module Bundler
    class SpecSet
      alias size length
    end
  end
end
