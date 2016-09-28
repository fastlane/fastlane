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
      content = File.read(path)

      # From https://github.com/orta/danger/blob/master/lib/danger/Dangerfile.rb
      if content.tr!('“”‘’‛', %(""'''))
        UI.error "Your #{File.basename(path)} has had smart quotes sanitised. " \
                'To avoid issues in the future, you should not use ' \
                'TextEdit for editing it. If you are not using TextEdit, ' \
                'you should turn off smart quotes in your editor of choice.'
      end

      parse(content, @path)
    end

    def parsing_binding
      binding
    end

    def parse(data, path = nil)
      @runner ||= Runner.new

      Dir.chdir(Fastlane::FastlaneFolder.path || Dir.pwd) do # context: fastlane subfolder
        # create nice path that we want to print in case of some problem
        relative_path = path.nil? ? '(eval)' : Pathname.new(path).relative_path_from(Pathname.new(Dir.pwd)).to_s

        begin
          # We have to use #get_binding method, because some test files defines method called `path` (for example SwitcherFastfile)
          # and local variable has higher priority, so it causes to remove content of original Fastfile for example. With #get_binding
          # is this always clear and safe to declare any local variables we want, because the eval function uses the instance scope
          # instead of local.

          # rubocop:disable Lint/Eval
          eval(data, parsing_binding, relative_path) # using eval is ok for this case
          # rubocop:enable Lint/Eval
        rescue SyntaxError => ex
          line = ex.to_s.match(/#{Regexp.escape(relative_path)}:(\d+)/)[1]
          UI.user_error!("Syntax error in your Fastfile on line #{line}: #{ex}")
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

    # Is executed if an error occured during fastlane execution
    def error(&block)
      @runner.set_error(@current_platform, block)
    end

    # Is used to look if the method is implemented as an action
    def method_missing(method_sym, *arguments, &_block)
      self.runner.trigger_action_by_name(method_sym, nil, *arguments)
    end

    #####################################################
    # @!group Other things
    #####################################################

    def collector
      runner.collector
    end

    # Is the given key a platform block or a lane?
    def is_platform_block?(key)
      UI.crash!('No key given') unless key

      return false if self.runner.lanes.fetch(nil, {}).fetch(key.to_sym, nil)
      return true if self.runner.lanes[key.to_sym].kind_of? Hash

      UI.user_error!("Could not find '#{key}'. Available lanes: #{self.runner.available_lanes.join(', ')}")
    end

    def actions_path(path)
      UI.crash!("Path '#{path}' not found!") unless File.directory?(path)

      Actions.load_external_actions(path)
    end

    # Execute shell command
    def sh(command)
      Actions.execute_action(command) do
        Actions.sh_no_action(command)
      end
    end

    def desc(string)
      desc_collection << string
    end

    def desc_collection
      @desc_collection ||= []
    end

    def import(path = nil)
      UI.user_error!("Please pass a path to the `import` action") unless path

      path = path.dup.gsub("~", Dir.home)
      unless Pathname.new(path).absolute? # unless an absolute path
        path = File.join(File.expand_path('..', @path), path)
      end

      UI.user_error!("Could not find Fastfile at path '#{path}'") unless File.exist?(path)

      collector.did_launch_action(:import)
      parse(File.read(path), path)

      # Check if we can also import local actions which are in the same directory as the Fastfile
      actions_path = File.join(File.expand_path("..", path), 'actions')
      Fastlane::Actions.load_external_actions(actions_path) if File.directory?(actions_path)
    end

    # @param url [String] The git URL to clone the repository from
    # @param branch [String] The branch to checkout in the repository
    # @param path [String] The path to the Fastfile
    def import_from_git(url: nil, branch: 'HEAD', path: 'fastlane/Fastfile')
      UI.user_error!("Please pass a path to the `import_from_git` action") if url.to_s.length == 0

      Actions.execute_action('import_from_git') do
        require 'tmpdir'

        collector.did_launch_action(:import_from_git)

        # Checkout the repo
        repo_name = url.split("/").last

        tmp_path = Dir.mktmpdir("fl_clone")
        clone_folder = File.join(tmp_path, repo_name)

        branch_option = ""
        branch_option = "--branch #{branch}" if branch != 'HEAD'

        clone_command = "GIT_TERMINAL_PROMPT=0 git clone '#{url}' '#{clone_folder}' --depth 1 -n #{branch_option}"

        UI.message "Cloning remote git repo..."
        Actions.sh(clone_command)

        Actions.sh("cd '#{clone_folder}' && git checkout #{branch} '#{path}'")

        # We also want to check out all the local actions of this fastlane setup
        containing = path.split(File::SEPARATOR)[0..-2]
        containing = "." if containing.count == 0
        actions_folder = File.join(containing, "actions")
        begin
          Actions.sh("cd '#{clone_folder}' && git checkout #{branch} '#{actions_folder}'")
        rescue
          # We don't care about a failure here, as local actions are optional
        end

        import(File.join(clone_folder, path))

        if Dir.exist?(clone_folder)
          # We want to re-clone if the folder already exists
          UI.message "Clearing the git repo..."
          Actions.sh("rm -rf '#{tmp_path}'")
        end
      end
    end

    #####################################################
    # @!group Overwriting Ruby methods
    #####################################################

    # Speak out loud
    def say(value)
      # Overwrite this, since there is already a 'say' method defined in the Ruby standard library
      value ||= yield
      Actions.execute_action('say') do
        collector.did_launch_action(:say)
        Fastlane::Actions::SayAction.run([value])
      end
    end

    def puts(value)
      # Overwrite this, since there is already a 'puts' method defined in the Ruby standard library
      value ||= yield if block_given?
      collector.did_launch_action(:puts)
      Fastlane::Actions::PutsAction.run([value])
    end

    def test(params = {})
      # Overwrite this, since there is already a 'test' method defined in the Ruby standard library
      self.runner.try_switch_to_lane(:test, [params])
    end
  end
end
