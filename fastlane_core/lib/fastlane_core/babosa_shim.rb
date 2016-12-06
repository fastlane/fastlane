if Unicode
  orig_unicode = Unicode
end
Object.send(:remove_const, :Unicode) if defined?(Unicode)
require "babosa"
Object.send(:const_set, :Unicode, orig_unicode)
