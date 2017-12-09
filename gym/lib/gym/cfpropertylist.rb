# To be used instead of require "cfpropertylist". Restores extensions from
# Plist overwritten by CFPropertyList.

require "cfpropertylist"
require "plist"

# Brute-force solution to conflict between #to_plist introduced by
# CFPropertyList and plist. Remove the method added by CFPropertyList
# and restore the method from Plist::Emit. Each class gains a
# #to_binary_plist method equivalent to #to_plist from CFPropertyList.
# However, this may not enable generation of binary plists with
# CFPropertyList, which will not call the renamed method.
[Array, Enumerator, Hash].each do |c|
  c.send :alias_method, :to_binary_plist, :to_plist
  c.send :remove_method, :to_plist
  c.include Plist::Emit
end
