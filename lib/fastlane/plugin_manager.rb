# encoding: utf-8

# Originally from https://github.com/CocoaPods/CLAide/blob/master/lib/claide/command/plugin_manager.rb

# Copyright (c) 2011 - 2012 Eloy Durán <eloy.de.enige@gmail.com>
# Copyright (c)        2012 Fabio Pelosin <fabiopelosin@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

module Fastlane
  # Handles plugin related logic logic for the `Action` class.
  #
  # Plugins are loaded the first time a command run and are identified by the
  # prefix specified in the command class. Plugins must adopt the following
  # conventions:
  #
  # - Support being loaded by a file located under the
  # `lib/#{plugin_prefix}_plugin` relative path.
  # - Be stored in a folder named after the plugin.
  #
  class PluginManager
    # @return [Array<Pathname>] The list of the root directories of the
    #         loaded plugins.
    #
    def self.plugin_paths
      @plugin_paths ||= {}
    end

    # @return [Array<String>] Loads plugins via RubyGems looking for files
    #         named after the `PLUGIN_PREFIX_plugin` and returns the paths of
    #         the gems loaded successfully. Plugins are required safely.
    #
    def self.load_plugins(plugin_prefix)
      return if plugin_paths[plugin_prefix]

      loaded_paths = []
      plugin_load_paths(plugin_prefix).each do |path|
        if safe_require(path.to_s)
          loaded_paths << Pathname(path + './../../').cleanpath
        end
      end

      plugin_paths[plugin_prefix] = loaded_paths
    end

    # @return [Array<Specification>] The RubyGems specifications for the
    #         loaded plugins.
    #
    def self.specifications
      plugin_paths.values.flatten.map do |path|
        specification(path)
      end.compact
    end

    # @return [Specification] The RubyGems specification for the plugin at the
    #         given path.
    #
    # @param  [#to_s] path
    #         The root path of the plugin.
    #
    def self.specification(path)
      matches = Dir.glob("#{path}/*.gemspec")
      spec = silence_streams(STDERR) do
        Gem::Specification.load(matches.first)
      end if matches.count == 1
      unless spec
        warn '[!] Unable to load a specification for the plugin ' \
          "`#{path}`".yellow
      end
      spec
    end

    # @return [Array<String>] The list of the plugins whose root path appears
    #         in the backtrace of an exception.
    #
    # @param  [Exception] exception
    #         The exception to analyze.
    #
    def self.plugins_involved_in_exception(exception)
      paths = plugin_paths.values.flatten.select do |plugin_path|
        exception.backtrace.any? { |line| line.include?(plugin_path.to_s) }
      end
      paths.map { |path| path.to_s.split('/').last }
    end

    # Returns the paths of the files to require to load the available
    # plugins.
    #
    # @return [Array] The found plugins load paths.
    #
    def self.plugin_load_paths(plugin_prefix)
      if plugin_prefix && !plugin_prefix.empty?
        pattern = "#{plugin_prefix}_plugin"
        if Gem.respond_to? :find_latest_files
          Gem.find_latest_files(pattern)
        else
          Gem.find_files(pattern)
        end
      else
        []
      end
    end

    # Loads the given path. If any exception occurs it is catched and an
    # informative message is printed.
    #
    # @param  [String] path
    #         The path to load
    #
    # rubocop:disable RescueException
    def self.safe_require(path)
      require path
      true
    end
    # rubocop:enable RescueException

    # Executes the given block while silencing the given streams.
    #
    # @return [Object] The value of the given block.
    #
    # @param [Array] streams
    #                The streams to silence.
    #
    # @note credit to DHH http://stackoverflow.com/a/8959520
    #
    def self.silence_streams(*streams)
      on_hold = streams.map(&:dup)
      streams.each do |stream|
        stream.reopen('/dev/null')
        stream.sync = true
      end
      yield
    ensure
      streams.each_with_index do |stream, i|
        stream.reopen(on_hold[i])
      end
    end
  end
end
