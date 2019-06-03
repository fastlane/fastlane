require "rubygems/requirement"

module Fastlane
  class FastFile
    # Stores all relevant information from the currently running process
    attr_accessor :runner

    # the platform in which we're currently in when parsing the Fastfile
    # This is used to identify the platform in which the lane is in
    attr_accessor :current_platform

    SharedValues = Fastlane::Actions::SharedValues

    # @return The runner which can be executed to trigger the given actions
    def initialize(path = nil)
      return unless (path || '').length > 0
      UI.user_error!("Could not find Fastfile at path '#{path}'") unless File.exist?(path)
      @path = File.expand_path(path)
      content = File.read(path, encoding: "utf-8")

      # From https://github.com/orta/danger/blob/master/lib/danger/Dangerfile.rb
      if content.tr!('“”‘’‛', %(""'''))
        UI.error("Your #{File.basename(path)} has had smart quotes sanitised. " \
                'To avoid issues in the future, you should not use ' \
                'TextEdit for editing it. If you are not using TextEdit, ' \
                'you should turn off smart quotes in your editor of choice.')
      end

      content.scan(/^\s*require (.*)/).each do |current|
        gem_name = current.last
        next if gem_name.include?(".") # these are local gems
        UI.important("You have required a gem, if this is a third party gem, please use `fastlane_require #{gem_name}` to ensure the gem is installed locally.")
      end

      parse(content, @path)
    end

    def parsing_binding
      binding
    end

    def parse(data, path = nil)
      @runner ||= Runner.new

      Dir.chdir(FastlaneCore::FastlaneFolder.path || Dir.pwd) do # context: fastlane subfolder
        # create nice path that we want to print in case of some problem
        relative_path = path.nil? ? '(eval)' : Pathname.new(path).relative_path_from(Pathname.new(Dir.pwd)).to_s

        begin
          # We have to use #get_binding method, because some test files defines method called `path` (for example SwitcherFastfile)
          # and local variable has higher priority, so it causes to remove content of original Fastfile for example. With #get_binding
          # is this always clear and safe to declare any local variables we want, because the eval function uses the instance scope
          # instead of local.

          # rubocop:disable Security/Eval
          eval(data, parsing_binding, relative_path) # using eval is ok for this case
          # rubocop:enable Security/Eval
        rescue SyntaxError => ex
          match = ex.to_s.match(/#{Regexp.escape(relative_path)}:(\d+)/)
          if match
            line = match[1]
            UI.content_error(data, line)
            UI.user_error!("Syntax error in your Fastfile on line #{line}: #{ex}")
          else
            UI.user_error!("Syntax error in your Fastfile: #{ex}")
          end
        end
      end

      self
    end

    #####################################################
    # @!group DSL
    #####################################################

    # User defines a new lane
    def lane(lane_name, &block)
      UI.user_error!("You have to pass a block using 'do' for lane '#{lane_name}'. Make sure you read the docs on GitHub.") unless block

      self.runner.add_lane(Lane.new(platform: self.current_platform,
                                       block: block,
                                 description: desc_collection,
                                        name: lane_name,
                                  is_private: false))

      @desc_collection = nil # reset the collected description again for the next lane
    end

    # User defines a new private lane, which can't be called from the CLI
    def private_lane(lane_name, &block)
      UI.user_error!("You have to pass a block using 'do' for lane '#{lane_name}'. Make sure you read the docs on GitHub.") unless block

      self.runner.add_lane(Lane.new(platform: self.current_platform,
                                       block: block,
                                 description: desc_collection,
                                        name: lane_name,
                                  is_private: true))

      @desc_collection = nil # reset the collected description again for the next lane
    end

    # User defines a lane that can overwrite existing lanes. Useful when importing a Fastfile
    def override_lane(lane_name, &block)
      UI.user_error!("You have to pass a block using 'do' for lane '#{lane_name}'. Make sure you read the docs on GitHub.") unless block

      self.runner.add_lane(Lane.new(platform: self.current_platform,
                                       block: block,
                                 description: desc_collection,
                                        name: lane_name,
                                  is_private: false), true)

      @desc_collection = nil # reset the collected description again for the next lane
    end

    # User defines a platform block
    def platform(platform_name)
      SupportedPlatforms.verify!(platform_name)

      self.current_platform = platform_name

      yield

      self.current_platform = nil
    end

    # Is executed before each test run
    def before_all(&block)
      @runner.set_before_all(@current_platform, block)
    end

    # Is executed before each lane
    def before_each(&block)
      @runner.set_before_each(@current_platform, block)
    end

    # Is executed after each test run
    def after_all(&block)
      @runner.set_after_all(@current_platform, block)
    end

    # Is executed before each lane
    def after_each(&block)
      @runner.set_after_each(@current_platform, block)
    end

    # Is executed if an error occurred during fastlane execution
    def error(&block)
      @runner.set_error(@current_platform, block)
    end

    # Is used to look if the method is implemented as an action
    def method_missing(method_sym, *arguments, &_block)
      self.runner.trigger_action_by_name(method_sym, nil, false, *arguments)
    end

    #####################################################
    # @!group Other things
    #####################################################

    # Is the given key a platform block or a lane?
    def is_platform_block?(key)
      UI.crash!('No key given') unless key

      return false if self.runner.lanes.fetch(nil, {}).fetch(key.to_sym, nil)
      return true if self.runner.lanes[key.to_sym].kind_of?(Hash)

      if key.to_sym == :update
        # The user ran `fastlane update`, instead of `fastlane update_fastlane`
        # We're gonna be nice and understand what the user is trying to do
        require 'fastlane/one_off'
        Fastlane::OneOff.run(action: "update_fastlane", parameters: {})
      else
        UI.user_error!("Could not find '#{key}'. Available lanes: #{self.runner.available_lanes.join(', ')}")
      end
    end

    def actions_path(path)
      UI.crash!("Path '#{path}' not found!") unless File.directory?(path)

      Actions.load_external_actions(path)
    end

    # Execute shell command
    def sh(*command, log: true, error_callback: nil, &b)
      FastFile.sh(*command, log: log, error_callback: error_callback, &b)
    end

    def self.sh(*command, log: true, error_callback: nil, &b)
      command_header = log ? Actions.shell_command_from_args(*command) : "shell command"
      Actions.execute_action(command_header) do
        Actions.sh_no_action(*command, log: log, error_callback: error_callback, &b)
      end
    end

    def desc(string)
      desc_collection << string
    end

    def desc_collection
      @desc_collection ||= []
    end

    def fastlane_require(gem_name)
      FastlaneRequire.install_gem_if_needed(gem_name: gem_name, require_gem: true)
    end

    def generated_fastfile_id(id)
      UI.important("The `generated_fastfile_id` action was deprecated, you can remove the line from your `Fastfile`")
    end

    def import(path = nil)
      UI.user_error!("Please pass a path to the `import` action") unless path

      path = path.dup.gsub("~", Dir.home)
      unless Pathname.new(path).absolute? # unless an absolute path
        path = File.join(File.expand_path('..', @path), path)
      end

      UI.user_error!("Could not find Fastfile at path '#{path}'") unless File.exist?(path)

      # First check if there are local actions to import in the same directory as the Fastfile
      actions_path = File.join(File.expand_path("..", path), 'actions')
      Fastlane::Actions.load_external_actions(actions_path) if File.directory?(actions_path)

      action_launched('import')

      return_value = parse(File.read(path), path)

      action_completed('import', status: FastlaneCore::ActionCompletionStatus::SUCCESS)

      return return_value
    end

    # @param url [String] The git URL to clone the repository from
    # @param branch [String] The branch to checkout in the repository
    # @param path [String] The path to the Fastfile
    # @param version [String, Array] Version requirement for repo tags
    def import_from_git(url: nil, branch: 'HEAD', path: 'fastlane/Fastfile', version: nil)
      UI.user_error!("Please pass a path to the `import_from_git` action") if url.to_s.length == 0

      Actions.execute_action('import_from_git') do
        require 'tmpdir'

        action_launched('import_from_git')

        # Checkout the repo
        repo_name = url.split("/").last
        checkout_param = branch

        Dir.mktmpdir("fl_clone") do |tmp_path|
          clone_folder = File.join(tmp_path, repo_name)

          branch_option = "--branch #{branch}" if branch != 'HEAD'

          UI.message("Cloning remote git repo...")
          Helper.with_env_values('GIT_TERMINAL_PROMPT' => '0') do
            Actions.sh("git clone #{url.shellescape} #{clone_folder.shellescape} --depth 1 -n #{branch_option}")
          end

          unless version.nil?
            req = Gem::Requirement.new(version)
            all_tags = fetch_remote_tags(folder: clone_folder)
            checkout_param = all_tags.select { |t| req =~ FastlaneCore::TagVersion.new(t) }.last
            UI.user_error!("No tag found matching #{version.inspect}") if checkout_param.nil?
          end

          Actions.sh("cd #{clone_folder.shellescape} && git checkout #{checkout_param.shellescape} #{path.shellescape}")

          # We also want to check out all the local actions of this fastlane setup
          containing = path.split(File::SEPARATOR)[0..-2]
          containing = "." if containing.count == 0
          actions_folder = File.join(containing, "actions")
          begin
            Actions.sh("cd #{clone_folder.shellescape} && git checkout #{checkout_param.shellescape} #{actions_folder.shellescape}")
          rescue
            # We don't care about a failure here, as local actions are optional
          end

          return_value = import(File.join(clone_folder, path))

          action_completed('import_from_git', status: FastlaneCore::ActionCompletionStatus::SUCCESS)

          return return_value
        end
      end
    end

    #####################################################
    # @!group Versioning helpers
    #####################################################

    def fetch_remote_tags(folder: nil)
      UI.message("Fetching remote git tags...")
      Helper.with_env_values('GIT_TERMINAL_PROMPT' => '0') do
        Actions.sh("cd #{folder.shellescape} && git fetch --all --tags -q")
      end

      # Fetch all possible tags
      git_tags_string = Actions.sh("cd #{folder.shellescape} && git tag -l")
      git_tags = git_tags_string.split("\n")

      # Sort tags based on their version number
      return git_tags
             .select { |tag| FastlaneCore::TagVersion.correct?(tag) }
             .sort_by { |tag| FastlaneCore::TagVersion.new(tag) }
    end

    #####################################################
    # @!group Overwriting Ruby methods
    #####################################################

    # Speak out loud
    def say(value)
      # Overwrite this, since there is already a 'say' method defined in the Ruby standard library
      value ||= yield

      value = { text: value } if value.kind_of?(String) || value.kind_of?(Array)
      self.runner.trigger_action_by_name(:say, nil, false, value)
    end

    def puts(value)
      # Overwrite this, since there is already a 'puts' method defined in the Ruby standard library
      value ||= yield if block_given?

      action_launched('puts')
      return_value = Fastlane::Actions::PutsAction.run([value])
      action_completed('puts', status: FastlaneCore::ActionCompletionStatus::SUCCESS)
      return return_value
    end

    def test(params = {})
      # Overwrite this, since there is already a 'test' method defined in the Ruby standard library
      self.runner.try_switch_to_lane(:test, [params])
    end

    def action_launched(action_name)
      action_launch_context = FastlaneCore::ActionLaunchContext.context_for_action_name(action_name,
                                                                                        fastlane_client_language: :ruby,
                                                                                        args: ARGV)
      FastlaneCore.session.action_launched(launch_context: action_launch_context)
    end

    def action_completed(action_name, status: nil)
      completion_context = FastlaneCore::ActionCompletionContext.context_for_action_name(action_name,
                                                                                         args: ARGV,
                                                                                         status: status)
      FastlaneCore.session.action_completed(completion_context: completion_context)
    end
  end
end
