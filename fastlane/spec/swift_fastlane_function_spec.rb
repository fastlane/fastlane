describe Fastlane do
  describe Fastlane::SwiftFunction do
    describe 'swift_parameter_documentation' do
      it 'generates nil for functions with 0 parameters' do
        swift_function = Fastlane::SwiftFunction.new
        output = swift_function.swift_parameter_documentation

        expect(output).to be_nil
      end

      it 'generates parameter documentation for functions with 1 parameter' do
        swift_function = Fastlane::SwiftFunction.new(keys: ['param_one'], key_descriptions: ['desc for param one'])
        result = swift_function.swift_parameter_documentation

        expect(result).to eq(' - parameter paramOne: desc for param one')
      end

      it 'generates parameter documentation for functions with many parameters' do
        swift_function = Fastlane::SwiftFunction.new(keys: ['param_one', 'param_two'], key_descriptions: ['desc for param one', 'desc for param two'])
        result = swift_function.swift_parameter_documentation
        expected = " - parameters:\n"\
          "   - paramOne: desc for param one\n"\
          '   - paramTwo: desc for param two'

        expect(result).to eq(expected)
      end
    end

    describe 'swift_return_value_documentation' do
      it 'generates nil for fuctions with no return value' do
        swift_function = Fastlane::SwiftFunction.new
        result = swift_function.swift_return_value_documentation

        expect(result).to be_nil
      end

      it 'generates documentation for the return value' do
        swift_function = Fastlane::SwiftFunction.new(return_value: 'description of return value')
        result = swift_function.swift_return_value_documentation

        expect(result).to eq(" - returns: description of return value")
      end

      it 'generates documentation for the return value with a sample return value' do
        swift_function = Fastlane::SwiftFunction.new(return_value: 'description of return value', sample_return_value: '[]')
        result = swift_function.swift_return_value_documentation

        expect(result).to eq(" - returns: description of return value. Example: []")
      end
    end

    describe 'swift_documentation' do
      it 'generates empty string for functions with no parameters and no function details and no function description' do
        swift_function = Fastlane::SwiftFunction.new
        result = swift_function.swift_documentation

        expect(result).to be_empty
      end

      it 'generates documentation for functions with a parameter but no function details and no function description' do
        swift_function = Fastlane::SwiftFunction.new(keys: ['param_one'], key_descriptions: ['desc for param one'])
        result = swift_function.swift_documentation
        expected = "/**\n"\
          " - parameter paramOne: desc for param one\n"\
          "*/\n"

        expect(result).to eq(expected)
      end

      it 'generates documentation for functions with function details but no parameters and no function description' do
        swift_function = Fastlane::SwiftFunction.new(action_details: 'details')
        result = swift_function.swift_documentation
        expected = "/**\n"\
          " details\n"\
          "*/\n"

        expect(result).to eq(expected)
      end

      it 'generates documentation for functions with a function description but no parameters and no function details' do
        swift_function = Fastlane::SwiftFunction.new(action_description: 'description')
        result = swift_function.swift_documentation
        expected = "/**\n"\
          " description\n"\
          "*/\n"

        expect(result).to eq(expected)
      end

      it 'generates documentation for functions with function details and a parameter but no function description' do
        swift_function = Fastlane::SwiftFunction.new(action_details: 'details', keys: ['param_one'], key_descriptions: ['desc for param one'])
        result = swift_function.swift_documentation
        expected = "/**\n"\
          " - parameter paramOne: desc for param one\n"\
          "\n"\
          " details\n"\
          "*/\n"

        expect(result).to eq(expected)
      end

      it 'generates documentation for functions with function details, a parameter, and a function description' do
        swift_function = Fastlane::SwiftFunction.new(action_details: 'details', action_description: "description", keys: ['param_one'], key_descriptions: ['desc for param one'])
        result = swift_function.swift_documentation
        expected = "/**\n"\
          " description\n"\
          "\n"\
          " - parameter paramOne: desc for param one\n"\
          "\n"\
          " details\n"\
          "*/\n"

        expect(result).to eq(expected)
      end

      it 'generates documentation for functions with a parameter and a return value' do
        swift_function = Fastlane::SwiftFunction.new(keys: ['param_one'], key_descriptions: ['desc for param one'], return_value: 'return value')
        result = swift_function.swift_documentation
        expected = "/**\n"\
          " - parameter paramOne: desc for param one\n"\
          "\n"\
          " - returns: return value\n"\
          "*/\n"

        expect(result).to eq(expected)
      end
    end
  end

  describe Fastlane::ToolSwiftFunction do
    describe 'swift_vars' do
      it 'generates empty array for protocols without parameters' do
        swift_function = Fastlane::ToolSwiftFunction.new
        result = swift_function.swift_vars

        expect(result).to be_empty
      end

      it 'generates var without documentation' do
        swift_function = Fastlane::ToolSwiftFunction.new(
          keys: ['param_one'],
          key_default_values: [''],
          key_descriptions: [],
          key_optionality_values: [],
          key_type_overrides: []
        )
        result = swift_function.swift_vars

        expect(result).to eq(["\n  var paramOne: String { get }"])
      end

      it 'generates var with documentation' do
        swift_function = Fastlane::ToolSwiftFunction.new(
          keys: ['param_one'],
          key_default_values: [''],
          key_descriptions: ['key description'],
          key_optionality_values: [],
          key_type_overrides: []
        )
        result = swift_function.swift_vars

        expect(result).to eq(["\n  /// key description\n  var paramOne: String { get }"])
      end
    end
  end
end
