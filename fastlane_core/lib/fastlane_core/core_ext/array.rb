class Array
  # Workaround for Ruby 2.0.0 support. Array#to_h was introduced in Ruby 2.1.0.
  def fl_to_h
    if respond_to?(:to_h)
      return to_h
    else
      # C implementation from 2.5.0:
      #               static VALUE
      # rb_ary_to_h(VALUE ary)
      # {
      #    long i;
      #    VALUE hash = rb_hash_new_with_size(RARRAY_LEN(ary));
      #    for (i=0; i<RARRAY_LEN(ary); i++) {
      #        const VALUE elt = rb_ary_elt(ary, i);
      #        const VALUE key_value_pair = rb_check_array_type(elt);
      #        if (NIL_P(key_value_pair)) {
      #            rb_raise(rb_eTypeError, "wrong element type %"PRIsVALUE" at %ld (expected array)",
      #                     rb_obj_class(elt), i);
      #        }
      #        if (RARRAY_LEN(key_value_pair) != 2) {
      #            rb_raise(rb_eArgError, "wrong array length at %ld (expected 2, was %ld)",
      #                i, RARRAY_LEN(key_value_pair));
      #        }
      #        rb_hash_aset(hash, RARRAY_AREF(key_value_pair, 0), RARRAY_AREF(key_value_pair, 1));
      #    }
      #    return hash;
      # }

      hash = {}

      each_with_index do |key_value_pair, index|
        raise TypeError, "wrong element type #{key_value_pair.class.name} at #{index} (expected array)" unless key_value_pair.kind_of?(Array)
        raise ArgumentError, "wrong array length at #{index} (expected 2, was #{key_value_pair.length})" unless key_value_pair.length == 2
        hash[key_value_pair[0]] = key_value_pair[1]
      end

      return hash
    end
  end
end
