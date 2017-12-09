# To be used instead of require "cfpropertylist". Restores extensions from
# Plist overwritten by CFPropertyList.

require "cfpropertylist"
require "plist"

module Gym
  # Module to determine if a module's VERSION constant meets a minimum requirement.
  #
  # @example Test Plist::VERSION
  #   module Plist
  #     extend Gym::VersionAtLeast
  #   end
  #
  #   Plist.version_at_least? "3.4.0"
  module VersionAtLeast
    # Determine if a modules VERSION constant meets a minimum requirement.
    #
    # @param minimum_version [String] A minimum version string to test against, e.g. "3.4.0"
    # @return [true] If the modules VERSION constant is semantically greater than or equal to the argument
    # @return [false] If the modules VERSION constant is semantically less than the argument
    def version_at_least?(minimum_version)
      current = const_get("VERSION").split(".").map(&:to_i)
      minimum = minimum_version.to_s.split(".").map(&:to_i)

      minimum.each_with_index do |min_component, index|
        return false if index >= current.count

        component = current[index]
        return false if component < min_component
      end

      return true
    end
  end
end

module Plist
  extend Gym::VersionAtLeast
end

# Brute-force solution to conflict between #to_plist introduced by
# CFPropertyList and plist. Make sure we always use Plist::Emit#to_plist,
# in effect.
[Array, Enumerator, Hash].each do |c|
  c.send :define_method, :to_plist do |envelope = true, options = {}|
    # It's not clear how to delegate this method directly to the Plist::Emit
    # module from here. Re-including the module does not work (or else require
    # 'plist' above would replace the method from CFPropertyList). For now, this
    # is dependent on the implementation of Plist::Emit#to_plist.

    if Plist.version_at_least? "3.4.0"
      # The API is gaining an optional parameter in 3.4.0
      options = { indent: Plist::Emit::DEFAULT_INDENT }.merge(options)
      Plist::Emit.dump self, envelope, options
    else
      Plist::Emit.dump self, envelope
    end
  end
end
