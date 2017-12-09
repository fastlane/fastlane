# To be used instead of require "cfpropertylist". Restores extensions from
# Plist overwritten by CFPropertyList.

require "cfpropertylist"
require "plist"

# Brute-force solution to conflict between #to_plist introduced by
# CFPropertyList and plist. Remove the method added by CFPropertyList
# and restore the method from Plist::Emit.
[Array, Enumerator, Hash].each do |c|
  c.send :remove_method, :to_plist
  c.include Plist::Emit
end
