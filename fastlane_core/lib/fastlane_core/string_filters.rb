class String
  # Truncates a given +text+ after a given <tt>length</tt> if +text+ is longer than <tt>length</tt>:
  #
  #   'Once upon a time, in a world far, far away'.truncate(28)
  #   # => "Once upon a time, in a wo..."
  #
  # Pass a string or regexp <tt>:separator</tt> to truncate +text+ at a natural break:
  #
  #   'Once upon a time, in a world far, far away'.truncate(28, separator: ' ')
  #   # => "Once upon a time, in a..."
  #
  #   'Once upon a time, in a world far, far away'.truncate(28, separator: /\s/)
  #   # => "Once upon a time, in a..."
  #
  # The last characters will be replaced with the <tt>:omission</tt> string (defaults to "...")
  # for a total length not exceeding <tt>length</tt>:
  #
  #   'And they found that many people were sleeping better.'.truncate(25, omission: '... (continued)')
  #   # => "And they f... (continued)"
  def truncate(truncate_at, options = {})
    return dup unless length > truncate_at

    omission = options[:omission] || '...'
    length_with_room_for_omission = truncate_at - omission.length
    stop = \
      if options[:separator]
        rindex(options[:separator], length_with_room_for_omission) || length_with_room_for_omission
      else
        length_with_room_for_omission
      end

    "#{self[0, stop]}#{omission}"
  end

  # Base taken from: https://www.ruby-forum.com/topic/57805
  def wordwrap(length = 80)
    return [] if length == 0
    self.gsub!(/(\S{#{length}})(?=\S)/, '\1 ')
    self.scan(/.{1,#{length}}(?:\s+|$)/)
  end

  # Base taken from: http://stackoverflow.com/a/12202205/1945875
  def middle_truncate(length = 20, options = {})
    omission = options[:omission] || '...'
    return self if self.length <= length + omission.length
    return self[0..length] if length < omission.length
    len = (length - omission.length) / 2
    s_len = len - length % 2
    self[0..s_len] + omission + self[self.length - len..self.length]
  end
end
