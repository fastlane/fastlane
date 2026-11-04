def before_each_frameit
  # Frameit.config is module level state, normally set by the commands generator.
  # Screenshot#initialize reads it, so a spec that builds a Screenshot without
  # setting it depends on an earlier example having left one behind, and fails
  # with "undefined method '[]' for nil" when it runs first. Give every example
  # an empty one to start from; specs that need a populated config still set
  # their own, since example group hooks run after this one.
  Frameit.config = {}
end
