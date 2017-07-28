module RequiredParameters
  ##
  # RequiredParameters a mixin to provide a few methods for asserting the presense of named parameter.
  #
  # Background: fastlane uses Ruby 2.0's named parameters, but all named parameters in Ruby 2.0 must have a default value
  # Some parameters are not optional, and we must assert that they have values. Using this module, we can do that via the following pattern
  #
  # ```ruby
  #   def some_method(foo: nil, bar: nil, baz: nil) requires_params(:foo, :bar)
  #     .
  #     .
  #     .
  #   end
  #
  #   when `some_method()` is called, `foo` and `bar` must be non-nil
  # ```
  def requires_params!(*args)
    assert_required_params(__callee__, binding, args)
  end

  def requires_all_params!
    assert_required_params(__callee__, binding, all_method_parameters(__callee__))
  end

  private

  def assert_required_params(method_name, binding, parameter_names)
    parameter_names.each do |name|
      if local_variable_get(binding, name).nil?
        raise NameError, "`#{name}' is a required parameter"
      end
    end
  end

  def all_method_parameters(method_name)
    method(method_name).parameters.map { |k, v| v }
  end

  def local_variable_get(binding, name)
    if binding.respond_to?(:local_variable_get)
      binding.local_variable_get(name)
    else
      binding.eval(name.to_s)
    end
  end
end
