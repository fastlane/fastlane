module Fastlane
  module Actions
    module SharedValues
    end

    class SetInfoPlistValueAction < Action
      def self.run(params)
        require 'plist'

        begin
          path = File.expand_path(params[:path])
          plist = Plist.parse_xml(path)
          if params[:hash]
            plist = hash(plist, params[:hash], params[:replace])
          elsif params[:subkey]
            plist = subkey(plist, params[:key], params[:subkey], params[:value])
          else
            plist[params[:key]] = params[:value]
          end
          new_plist = Plist::Emit.dump(plist)
          if params[:output_file_name]
            output = params[:output_file_name]
            FileUtils.mkdir_p(File.expand_path("..", output))
            File.write(File.expand_path(output), new_plist)
          else
            File.write(path, new_plist)
          end

          return plist if params[:hash]
          return params[:value]
        rescue => ex
          UI.error(ex)
          UI.user_error!("Unable to set value to plist file at '#{path}'")
        end
      end

      def self.hash(plist, hash, replace = false)
        stringified_hash = deep_stringify(hash)
        if replace
          plist = stringified_hash
        else
          plist = deep_merge(plist, stringified_hash)
        end
        plist
      end

      def self.subkey(plist, key, subkey, value)
        if plist[key]
          plist[key][subkey] = value
        else
          UI.message "Key doesn't exist, going to create new one ..."
          plist[key] = { subkey => value }
        end
        plist
      end

      # Adapted from https://stackoverflow.com/a/30225093/158525
      # rubocop:disable Style/CaseEquality
      # rubocop:disable Style/MultilineTernaryOperator
      # rubocop:disable Style/NestedTernaryOperator
      def self.deep_merge(a, b)
        merger = proc do |key, v1, v2|
          Hash === v1 && Hash === v2 ?
                 v1.merge(v2, &merger) : Array === v1 && Array === v2 ?
                   array_deep_merge(v1, v2) : [:undefined, nil, :nil].include?(v2) ? v1 : v2
        end
        a.merge(b, &merger)
      end
      # rubocop:enable Style/CaseEquality
      # rubocop:enable Style/MultilineTernaryOperator
      # rubocop:enable Style/NestedTernaryOperator

      # Adapted from https://github.com/danielsdeleo/deep_merge/blob/86f15a04bc6cee3723125de6165a6b43b55f1cde/lib/deep_merge/core.rb#L174-L186
      def self.array_deep_merge(source, dest)
        source_all_hashes = source.all? { |i| i.kind_of?(Hash) }
        dest_all_hashes = dest.all? { |i| i.kind_of?(Hash) }
        if source_all_hashes && dest_all_hashes
          # merge hashes in lists
          list = []
          dest.each_index do |i|
            list[i] = deep_merge(source[i] || {}, dest[i])
          end
          list += source[dest.count..-1] if source.count > dest.count
          dest = list
        else
          dest = source | dest
        end
        dest
      end

      def self.deep_stringify(obj)
        if obj.kind_of?(Hash)
          stringified_hash ||= {}
          obj.each do |k, v|
            stringified_hash[k.to_s] = deep_stringify(v)
          end
          return stringified_hash
        end
        if obj.kind_of?(Array)
          stringified_array ||= []
          obj.each do |v|
            stringified_array << deep_stringify(v)
          end
          return stringified_array
        end
        obj
      end

      def self.description
        "Sets value to Info.plist of your project as native Ruby data structures"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :key,
                                       env_name: "FL_SET_INFO_PLIST_PARAM_NAME",
                                       description: "Name of key in plist",
                                       conflicting_options: [:hash],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :subkey,
                                       env_name: "FL_SET_INFO_PLIST_SUBPARAM_NAME",
                                       description: "Name of subkey in plist",
                                       conflicting_options: [:hash],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :value,
                                       env_name: "FL_SET_INFO_PLIST_PARAM_VALUE",
                                       description: "Value to setup",
                                       is_string: false,
                                       conflicting_options: [:hash],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :hash,
                                       env_name: "FL_SET_INFO_PLIST_PARAM_HASH",
                                       description: "Hash of keys and values to be merged into plist",
                                       type: Hash,
                                       conflicting_options: [:key, :subkey, :value],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :replace,
                                       env_name: "FL_SET_INFO_PLIST_PARAM_REPLACE",
                                       description: "Replace plist with map instead of merging",
                                       is_string: false,
                                       default_value: false,
                                       conflicting_options: [:key, :subkey, :value],
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_SET_INFO_PLIST_PATH",
                                       description: "Path to plist file you want to update",
                                       optional: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find plist file at path '#{value}'") unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :output_file_name,
                                       env_name: "FL_SET_INFO_PLIST_OUTPUT_FILE_NAME",
                                       description: "Path to the output file you want to generate",
                                       optional: true)
        ]
      end

      def self.authors
        ["kohtenko", "uwehollatz", "casz"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end

      def self.example_code
        [
          'set_info_plist_value(
            path: "./Info.plist",
            key: "CFBundleIdentifier",
            value: "com.krausefx.app.beta"
          )',
          'set_info_plist_value(
            path: "./MyApp-Info.plist",
            key: "NSAppTransportSecurity",
            subkey: "NSAllowsArbitraryLoads",
            value: true,
            output_file_name: "./Info.plist"
          )',
          'set_info_plist_value(
            path: "./Info.plist",
            hash: {
              CFBundleIdentifier: "com.example.fastlane",
              CFBundleShortVersionString: "1.1.1",
              CFBundleVersion: "9999",
            }
          )'
        ]
      end

      def self.category
        :project
      end
    end
  end
end
