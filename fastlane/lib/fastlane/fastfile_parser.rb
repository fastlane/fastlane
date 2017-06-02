require 'parser'
require 'parser/current'
require 'pp'
require "terminal-table"
module Fastlane
  class FastfileParser
    attr_accessor :original_action

    def to_s
      "REMOVE_IT"
    end

    def lines
      @lines ||= []
    end

    def lanes
      @lanes ||= []
    end

    def actions
      @actions ||= []
    end

    def counters
      errors = lines.select { |key| key[:state] == :error }.length
      deprecations = lines.select { |key| key[:state] == :deprecated }.length
      infos = lines.select { |key| key[:state] == :infos }.length
      { errors: errors, deprecations: deprecations, infos: infos, all: errors + infos + deprecations }
    end

    def data
      { lanes: @lanes,  notices: @lines, actions: @actions }
    end

    def bad_options
      [:use_legacy_build_api]
    end

    def redacted
      rc = ""
      rc = @content
      self.class.secrets.each do |s|
        rc.gsub!(s, "#" * s.length)
      end
      rc
    end

    def platform_is_ok(action)
      has_platform = true
      # platform's set by commandline
      if @platforms && @platforms.length > 0
        has_platform = false
        @platforms.each do |pl|
          next unless action.respond_to?(:is_supported?)
          has_platform = action.is_supported?(pl.to_sym)
          if has_platform
            break
          end
        end
      end
      return has_platform
    end

    def action_deprecation(action, original_action_name)
      if action.respond_to?(:category)
        if action.category == :deprecated
          deprecated_notes = ""
          if action.respond_to?(:deprecated_notes)
            deprecated_notes = action.deprecated_notes
          end
          lines << { state: :deprecated, line: @line_number, msg: "Action `#{original_action_name}` is deprecated!\n #{deprecated_notes}" }
        end
      end
    end

    def filter_sensitive_options(o, args)
      if o.sensitive
        self.class.secrets << args.first[o.key.to_sym].to_s if args.first[o.key.to_sym] && !self.class.secrets.include?(args.first[o.key.to_sym].to_s)
        @action_vars.each do |e|
          self.class.secrets << e unless self.class.secrets.include?(e)
        end
      end
    end

    def run_import_from_git(args)
      fl = Fastlane::FastFile.new
      fl.runner = Runner.new
      path = fl.import_from_git(url: args.first[:url], branch: args.first[:branch] || "master", return_file: true)
      actions_path = File.join(path, 'actions')
      Fastlane::Actions.load_external_actions(actions_path) if File.directory?(actions_path)
      imported_file_content = File.read("#{path}/fastlane/Fastfile")
      fl_parser = FastfileParser.new(content: imported_file_content, filepath: @dirname, name: "Imported at #{@line_number}", change_dir: false, platforms: @platforms)

      fl_parser.analyze
      @content << "#########################################\n"
      @content << "# BEGIN import_from_git at: #{@line_number} BEGIN\n"
      @content << "#########################################\n"
      @content << imported_file_content
      @content << "#########################################\n"
      @content << "# END import_from_git at: #{@line_number} END\n"
      @content << "#########################################\n"
      fl_parser.lines.each do |l|
        lines << l
      end
    end

    def validate_options(options_available, args)
      return_data = {}
      if options_available.length > 0 && options_available.first.kind_of?(FastlaneCore::ConfigItem)
        begin
          supplied_options = args.first
          if @original_action.to_s == "sh"
            # this is required since the recent change to the sh action.
            unless supplied_options.kind_of?(Hash)
              supplied_options = { command: args.first }
            end
          end
          config = FastlaneCore::Configuration.new(options_available, supplied_options)
          return_data[:configuration] = config
          return return_data
        rescue => ex
          return_data[:error] = ex.message
          lines << { state: :error, line: @line_number, msg: "'#{@original_action}'  failed with:  `#{ex.message}`" }
          return return_data
        end
      end
    end

    def detect_bad_options(bad_options_in, args)
      return unless args.first.kind_of?(Hash)
      bad_options_in.each do |b|
        if args.first[b.to_sym]
          lines << { state: :error, line: @line_number, msg: "do not use this option '#{b.to_sym}'" }
        end
      end
    end

    def detect_deprecated_options(o, args)
      if o.deprecated && args.first[o.key.to_sym]
        lines << { state: :deprecated, line: @line_number, msg: "Use of deprecated option - '#{o.key}' - `#{o.deprecated}`" }
      end
    end

    def reset_output
      $stdout = STDOUT
      $stderr = STDERR
    end

    def fake_action(*args)
      return_data = { args: args.first }
      # return if there is no @original_action
      return return_data if @original_action.nil?

      # get the reference to the original_action
      a = Fastlane::Actions.action_class_ref(@original_action.to_sym)
      a = find_alias(@original_action.to_sym) unless a

      # no action ref can be found.
      return return_data unless a

      # check for deprecations
      action_deprecation(a, @original_action)

      # no args supplied, so we do not need to validate them
      return return_data if args.length <= 0

      # Get the imported file
      out_channel = StringIO.new
      $stdout = out_channel
      $stderr = out_channel
      if @original_action.to_s == "import_from_git"
        begin
          run_import_from_git(args)
        rescue
        end
      end
      # if platform is not selected return
      unless platform_is_ok(a)
        reset_output
        return return_data
      end

      options_available = a.available_options
      # no availaible options - return

      if options_available.nil?
        reset_output
        return return_data
      end

      # Validate Options
      validation_result = validate_options(options_available, args)
      return_data.merge!(validation_result)

      # get bad options
      detect_bad_options(bad_options, args)

      # get deprecated and sensitive's
      options_available.each do |o|
        next unless o.kind_of?(FastlaneCore::ConfigItem)
        filter_sensitive_options(o, args)
        detect_deprecated_options(o, args)
      end
      # reenabled output
      reset_output
      return_data
    end

    def self.secrets
      unless @secrets
        @secrets = []
      end
      @secrets
    end

    def dummy
      FastlaneCore::FastfileParser.new
    end

    def method_missing(sym, *args, &block)
      return "dummy" if sym.to_s == "to_str"
      dummy
    end

    def initialize(content: nil, filepath: nil, name: "Fastfile", change_dir: true, platforms: [])
      @filename = name
      @platforms = platforms
      @change_dir = change_dir
      @content = content
      @dirname = File.dirname(filepath)
      # find the path above the "fastlane/"
      if @dirname == "fastlane"
        @dirname = "."
      else
        @dirname = File.dirname(File.expand_path(filepath)).sub(%r{/fastlane$}, "")
      end
      unless filepath =~ %r{/}
        @dirname = "."
      end
      if File.directory?(filepath)
        @dirname = filepath
      end
      @ast = parse(content)
    rescue
      return nil
    end

    def analyze
      recursive_analyze(@ast)
      return make_table
    end

    def wrap_string(s, max)
      chars = []
      dist = 0
      s.chars.each do |c|
        chars << c
        dist += 1
        if c == "\n"
          dist = 0
        elsif dist == max
          dist = 0
          chars << "\n"
        end
      end
      chars = chars[0..-2] if chars.last == "\n"
      chars.join
    end

    def make_table
      #
      table_rows = []
      lines.sort_by { |k| k[:state] }.reverse.each do |l|
        status = l[:msg]
        linenr = l[:line].to_s
        level = l[:state].to_s.yellow
        emoji = "⚠️"
        if l[:state] == :error
          status = l[:msg]
          level = l[:state].to_s.red
          linenr = l[:line].to_s
          emoji = "❌"
        end
        if l[:state] == :info
          emoji = "ℹ️"
        end
        table_rows << [emoji, level + " ".white, linenr.to_s + " ".white, wrap_string(status, 100)]
      end

      if table_rows.length <= 0
        return nil
      end

      table = Terminal::Table.new(title: "Fastfile Validation Result (#{@dirname})".green, headings: ["#", "State", "File/Line#", "Notice"]) do |t|
        table_rows.each do |e|
          t << e

          t << :separator
        end
      end
      return table
    end

    def find(method_name)
      recursive_search_ast(@ast, method_name)
      return @method_source
    end

    private

    def parse(data)
      Parser::CurrentRuby.parse(data)
    rescue
      return nil
    end

    # from runner.rb -> should be in FastlaneCore or somewhere shared
    def find_alias(action_name)
      Actions.alias_actions.each do |key, v|
        next unless Actions.alias_actions[key]
        next unless Actions.alias_actions[key].include?(action_name)
        return key
      end
      nil
    end

    def recursive_analyze(ast)
      if ast.nil?
        UI.error("Parse error")
        return nil
      end
      ast.children.each do |child|
        next unless child.class.to_s == "Parser::AST::Node"

        if (child.type.to_s == "send") and (child.children[0].to_s == "" && child.children[1].to_s == "lane")
          @line_number = "#{@filename}:#{child.loc.expression.line}"
          lane_name = child.children[2].children.first
          lanes << lane_name
          if Fastlane::Actions.action_class_ref(lane_name)
            lines << { state: :info, line: @line_number, msg: "Name of the lane `#{lane_name}` already taken by action `#{lane_name}`" }
          end
        end

        if (child.type.to_s == "send") and ((Fastlane::Actions.action_class_ref(child.children[1].to_s) || find_alias(child.children[1].to_s)))
          src_code = child.loc.expression.source
          src_code.sub!(child.children[1].to_s, "fake_action")
          @line_number = "#{@filename}:#{child.loc.expression.line}"

          # matches = src_code.gsub!(/#\{.*\}/) do |sym|
          #  self.class.secrets << sym if !self.class.secrets.include?(sym)
          #  "########"
          # end
          copy_code = src_code.clone
          @action_vars = []
          src_code.scan(/#\{.*?\}/m) do |mtch|
            # Remove #{} vars - so that there are now accidentalliy replaced ones
            @action_vars << mtch unless self.class.secrets.include?(mtch)
            # copy_code.gsub!(mtch.first, "'#######'")
          end
          src_code = copy_code
          @original_action = child.children[1].to_s
          dropper = '

          '
          begin
            Dir.chdir(@dirname) do
              # rubocop:disable Security/Eval
              result = eval(dropper + src_code)
              # rubocop:enable Security/Eval
              actions << { action: @original_action, result: result, line: @line_number }
            end
          rescue => ex
            UI.important("PARSE ERROR") if $verbose
            UI.important ex.backtrace if $verbose
            UI.important("Exception: #{ex}") if $verbose
          end
        else
          recursive_analyze(child)
        end
      end
    end
  end
end
