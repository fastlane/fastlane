module Fastlane
  module Actions
    module SharedValues
      APPLEDOC_DOCUMENTATION_OUTPUT = :APPLEDOC_DOCUMENTATION_OUTPUT
    end

    class AppledocAction < Action
      ARGS_MAP = {
        input: "",
        output: "--output",
        templates: "--templates",
        docset_install_path: "--docset-install-path",
        include: "--include",
        ignore: "--ignore",
        exclude_output: "--exclude-output",
        index_desc: "--index-desc",
        project_name: "--project-name",
        project_version: "--project-version",
        project_company: "--project-company",
        company_id: "--company-id",
        create_html: "--create-html",
        create_docset: "--create-docset",
        install_docset: "--install-docset",
        publish_docset: "--publish-docset",
        no_create_docset: "--no-create-docset",
        html_anchors: "--html-anchors",
        clean_output: "--clean-output",
        docset_bundle_id: "--docset-bundle-id",
        docset_bundle_name: "--docset-bundle-name",
        docset_desc: "--docset-desc",
        docset_copyright: "--docset-copyright",
        docset_feed_name: "--docset-feed-name",
        docset_feed_url: "--docset-feed-url",
        docset_feed_formats: "--docset-feed-formats",
        docset_package_url: "--docset-package-url",
        docset_fallback_url: "--docset-fallback-url",
        docset_publisher_id: "--docset-publisher-id",
        docset_publisher_name: "--docset-publisher-name",
        docset_min_xcode_version: "--docset-min-xcode-version",
        docset_platform_family: "--docset-platform-family",
        docset_cert_issuer: "--docset-cert-issuer",
        docset_cert_signer: "--docset-cert-signer",
        docset_bundle_filename: "--docset-bundle-filename",
        docset_atom_filename: "--docset-atom-filename",
        docset_xml_filename: "--docset-xml-filename",
        docset_package_filename: "--docset-package-filename",
        options: "",
        crossref_format: "--crossref-format",
        exit_threshold: "--exit-threshold",
        docs_section_title: "--docs-section-title",
        warnings: "",
        logformat: "--logformat",
        verbose: "--verbose"
      }

      def self.run(params)
        unless Helper.test?
          UI.message("Install using `brew install homebrew/boneyard/appledoc`")
          UI.user_error!("appledoc not installed") if `which appledoc`.length == 0
        end

        params_hash = params.values

        # Check if an output path was given
        if params_hash[:output]
          Actions.lane_context[SharedValues::APPLEDOC_DOCUMENTATION_OUTPUT] = File.expand_path(params_hash[:output])
          create_output_dir_if_not_exists(params_hash[:output])
        end

        # Maps parameter hash to CLI args
        appledoc_args = params_hash_to_cli_args(params_hash)
        UI.success("Generating documentation.")
        cli_args = appledoc_args.join(' ')
        input_cli_arg = Array(params_hash[:input]).map(&:shellescape).join(' ')
        command = "appledoc #{cli_args}".strip + " " + input_cli_arg
        UI.verbose(command)
        Actions.sh(command)
      end

      def self.params_hash_to_cli_args(params)
        # Remove nil and false value params
        params = params.delete_if { |_, v| v.nil? || v == false }

        cli_args = []
        params.each do |key, value|
          args = ARGS_MAP[key]
          if args.empty?
            if key != :input
              cli_args << value
            end
          elsif value.kind_of?(Array)
            value.each do |v|
              cli_args << cli_param(args, v)
            end
          else
            cli_args << cli_param(args, value)
          end
        end

        return cli_args
      end

      def self.cli_param(k, v)
        value = (v != true && v.to_s.length > 0 ? "\"#{v}\"" : "")
        "#{k} #{value}".strip
      end

      def self.create_output_dir_if_not_exists(output_path)
        output_dir = File.dirname(output_path)

        # If the output directory doesn't exist, create it
        unless Dir.exist?(output_dir)
          FileUtils.mkpath(output_dir)
        end
      end

      def self.description
        "Generate Apple-like source code documentation from the source code"
      end

      def self.details
        "Runs `appledoc [OPTIONS] <paths to source dirs or files>` for the project"
      end

      def self.available_options
        [
          # PATHS
          FastlaneCore::ConfigItem.new(key: :input, env_name: "FL_APPLEDOC_INPUT", description: "Path(s) to source file directories or individual source files. Accepts a single path or an array of paths", is_string: false),
          FastlaneCore::ConfigItem.new(key: :output, env_name: "FL_APPLEDOC_OUTPUT", description: "Output path", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :templates, env_name: "FL_APPLEDOC_TEMPLATES", description: "Template files path", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_install_path, env_name: "FL_APPLEDOC_DOCSET_INSTALL_PATH", description: "DocSet installation path", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :include, env_name: "FL_APPLEDOC_INCLUDE", description: "Include static doc(s) at path", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :ignore, env_name: "FL_APPLEDOC_IGNORE", description: "Ignore given path", is_string: false, optional: true),
          FastlaneCore::ConfigItem.new(key: :exclude_output, env_name: "FL_APPLEDOC_EXCLUDE_OUTPUT", description: "Exclude given path from output", is_string: false, optional: true),
          FastlaneCore::ConfigItem.new(key: :index_desc, env_name: "FL_APPLEDOC_INDEX_DESC", description: "File including main index description", is_string: true, optional: true),

          # PROJECT INFO
          FastlaneCore::ConfigItem.new(key: :project_name, env_name: "FL_APPLEDOC_PROJECT_NAME", description: "Project name", is_string: true),
          FastlaneCore::ConfigItem.new(key: :project_version, env_name: "FL_APPLEDOC_PROJECT_VERSION", description: "Project version", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :project_company, env_name: "FL_APPLEDOC_PROJECT_COMPANY", description: "Project company", is_string: true),
          FastlaneCore::ConfigItem.new(key: :company_id, env_name: "FL_APPLEDOC_COMPANY_ID", description: "Company UTI (i.e. reverse DNS name)", is_string: true, optional: true),

          # OUTPUT GENERATION
          FastlaneCore::ConfigItem.new(key: :create_html, env_name: "FL_APPLEDOC_CREATE_HTML", description: "Create HTML", is_string: false, default_value: false),
          FastlaneCore::ConfigItem.new(key: :create_docset, env_name: "FL_APPLEDOC_CREATE_DOCSET", description: "Create documentation set", is_string: false, default_value: false),
          FastlaneCore::ConfigItem.new(key: :install_docset, env_name: "FL_APPLEDOC_INSTALL_DOCSET", description: "Install documentation set to Xcode", is_string: false, default_value: false),
          FastlaneCore::ConfigItem.new(key: :publish_docset, env_name: "FL_APPLEDOC_PUBLISH_DOCSET", description: "Prepare DocSet for publishing", is_string: false, default_value: false),
          FastlaneCore::ConfigItem.new(key: :no_create_docset, env_name: "FL_APPLEDOC_NO_CREATE_DOCSET", description: "Create HTML and skip creating a DocSet", is_string: false, default_value: false),
          FastlaneCore::ConfigItem.new(key: :html_anchors, env_name: "FL_APPLEDOC_HTML_ANCHORS", description: "The html anchor format to use in DocSet HTML", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :clean_output, env_name: "FL_APPLEDOC_CLEAN_OUTPUT", description: "Remove contents of output path before starting", is_string: false, default_value: false),

          # DOCUMENTATION SET INFO
          FastlaneCore::ConfigItem.new(key: :docset_bundle_id, env_name: "FL_APPLEDOC_DOCSET_BUNDLE_ID", description: "DocSet bundle identifier", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_bundle_name, env_name: "FL_APPLEDOC_DOCSET_BUNDLE_NAME", description: "DocSet bundle name", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_desc, env_name: "FL_APPLEDOC_DOCSET_DESC", description: "DocSet description", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_copyright, env_name: "FL_APPLEDOC_DOCSET_COPYRIGHT", description: "DocSet copyright message", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_feed_name, env_name: "FL_APPLEDOC_DOCSET_FEED_NAME", description: "DocSet feed name", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_feed_url, env_name: "FL_APPLEDOC_DOCSET_FEED_URL", description: "DocSet feed URL", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_feed_formats, env_name: "FL_APPLEDOC_DOCSET_FEED_FORMATS", description: "DocSet feed formats. Separated by a comma [atom,xml]", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_package_url, env_name: "FL_APPLEDOC_DOCSET_PACKAGE_URL", description: "DocSet package (.xar) URL", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_fallback_url, env_name: "FL_APPLEDOC_DOCSET_FALLBACK_URL", description: "DocSet fallback URL", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_publisher_id, env_name: "FL_APPLEDOC_DOCSET_PUBLISHER_ID", description: "DocSet publisher identifier", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_publisher_name, env_name: "FL_APPLEDOC_DOCSET_PUBLISHER_NAME", description: "DocSet publisher name", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_min_xcode_version, env_name: "FL_APPLEDOC_DOCSET_MIN_XCODE_VERSION", description: "DocSet min. Xcode version", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_platform_family, env_name: "FL_APPLEDOC_DOCSET_PLATFORM_FAMILY", description: "DocSet platform family", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_cert_issuer, env_name: "FL_APPLEDOC_DOCSET_CERT_ISSUER", description: "DocSet certificate issuer", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_cert_signer, env_name: "FL_APPLEDOC_DOCSET_CERT_SIGNER", description: "DocSet certificate signer", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_bundle_filename, env_name: "FL_APPLEDOC_DOCSET_BUNDLE_FILENAME", description: "DocSet bundle filename", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_atom_filename, env_name: "FL_APPLEDOC_DOCSET_ATOM_FILENAME", description: "DocSet atom feed filename", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_xml_filename, env_name: "FL_APPLEDOC_DOCSET_XML_FILENAME", description: "DocSet xml feed filename", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :docset_package_filename, env_name: "FL_APPLEDOC_DOCSET_PACKAGE_FILENAME", description: "DocSet package (.xar,.tgz) filename", is_string: true, optional: true),

          # OPTIONS
          FastlaneCore::ConfigItem.new(key: :options, env_name: "FL_APPLEDOC_OPTIONS", description: "Documentation generation options", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :crossref_format, env_name: "FL_APPLEDOC_OPTIONS_CROSSREF_FORMAT", description: "Cross reference template regex", is_string: true, optional: true),
          FastlaneCore::ConfigItem.new(key: :exit_threshold, env_name: "FL_APPLEDOC_OPTIONS_EXIT_THRESHOLD", description: "Exit code threshold below which 0 is returned", is_string: false, default_value: 2, optional: true),
          FastlaneCore::ConfigItem.new(key: :docs_section_title, env_name: "FL_APPLEDOC_OPTIONS_DOCS_SECTION_TITLE", description: "Title of the documentation section (defaults to \"Programming Guides\"", is_string: true, optional: true),

          # WARNINGS
          FastlaneCore::ConfigItem.new(key: :warnings, env_name: "FL_APPLEDOC_WARNINGS", description: "Documentation generation warnings", is_string: true, optional: true),

          # MISCELLANEOUS
          FastlaneCore::ConfigItem.new(key: :logformat, env_name: "FL_APPLEDOC_LOGFORMAT", description: "Log format [0-3]", is_string: false, optional: true),
          FastlaneCore::ConfigItem.new(key: :verbose, env_name: "FL_APPLEDOC_VERBOSE", description: "Log verbosity level [0-6,xcode]", is_string: false, optional: true)
        ]
      end

      def self.output
        [
          ['APPLEDOC_DOCUMENTATION_OUTPUT', 'Documentation set output path']
        ]
      end

      def self.authors
        ["alexmx"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.category
        :documentation
      end

      def self.example_code
        [
          'appledoc(
            project_name: "MyProjectName",
            project_company: "Company Name",
            input: [
              "MyProjectSources",
              "MyProjectSourceFile.h"
            ],
            ignore: [
              "ignore/path/1",
              "ingore/path/2"
            ],
            options: "--keep-intermediate-files --search-undocumented-doc",
            warnings: "--warn-missing-output-path --warn-missing-company-id"
          )'
        ]
      end
    end
  end
end
