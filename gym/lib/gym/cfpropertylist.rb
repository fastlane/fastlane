require 'cfpropertylist'
require 'plist'

# Brute-force solution to conflict between #to_plist introduced by
# CFPropertyList and plist. Make sure we always use Plist::Emit#to_plist,
# in effect.
[Array, Enumerator, Hash].each do |c|
  c.send :define_method, :to_plist do
    Plist::Emit.dump self
  end
end
