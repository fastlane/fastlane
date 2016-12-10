# Babosa has a conflict with the unicode-string_width gem. unicode-string_width defines
# a module called `Unicode`, but Babosa uses the presence of this constant as
# the sign that it should try to require the `unicode` gem, which will not be present.
#
# We don't want to introduce the `unicode` gem because it depends on native extensions.
#
# This works around the possibility that the unicode-string_width gem may already be
# loaded by temporarily undefining the `Unicode` constant while we load Babosa,
# then restoring it to its previous state if necessary.
#
# Can be removed once https://github.com/norman/babosa/pull/42 is merged and released
class BabosaFix
  def apply
    unicode_removed = false

    if defined? Unicode
      orig_unicode = Unicode
      Object.send(:remove_const, :Unicode)
      unicode_removed = true
    end

    require 'babosa'

    if unicode_removed
      Object.send(:const_set, :Unicode, orig_unicode)
    end
  end
end

BabosaFix.new.apply
