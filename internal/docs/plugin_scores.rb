module Fastlane
  module Internal
    module Docs
      module PluginScores
        require 'faraday'
        require 'faraday/follow_redirects'
        require 'yaml'
        require 'date'

        class FastlanePluginRating
          attr_accessor :key
          attr_accessor :description
          attr_accessor :value

          def initialize(key: nil, description: nil, value: nil)
            self.key = key
            self.description = description
            self.value = value
          end
        end

        class FastlanePluginAction
          attr_accessor :name
          attr_accessor :category
          attr_accessor :description
          attr_accessor :details

          def initialize(name: nil, category: nil, description: nil, details: nil)
            self.name = name
            self.category = category
            self.description = description
            self.details = details
          end
        end

        class FastlanePluginScore
          attr_accessor :name
          attr_accessor :downloads
          attr_accessor :info
          attr_accessor :homepage
          attr_accessor :raw_hash

          attr_accessor :data
          attr_accessor :cache

          # Bump to refetch every plugin, e.g. when a new value is added to the cache
          CACHE_VERSION = 2

          # The homepage is later called with GITHUB_API_TOKEN, so only an exact github.com host qualifies
          def self.github_page?(url)
            uri = URI.parse(url.to_s)
            uri.kind_of?(URI::HTTPS) && uri.host == "github.com"
          rescue URI::InvalidURIError
            false
          end

          def initialize(hash, cache_path)
            if ENV["GITHUB_USER_NAME"].to_s.length == 0 || ENV["GITHUB_API_TOKEN"].to_s.length == 0
              raise "Missing ENV variables GITHUB_USER_NAME and/or GITHUB_API_TOKEN"
            end

            self.name = hash["name"]
            self.downloads = hash["downloads"]
            self.info = hash["info"]
            self.homepage = hash["homepage_uri"] || hash["documentation_uri"]
            self.raw_hash = hash

            has_github_page = self.class.github_page?(self.homepage) # Here we can add non GitHub support one day

            self.data = {
              has_homepage: self.homepage.to_s.length > 5,
              has_info: self.info.to_s.length > 5,
              downloads: self.downloads,
              has_github_page: has_github_page,
              public_github_repo: nil, # stays nil unless the homepage is on GitHub
              has_mit_license: includes_license?("MIT"),
              has_gnu_license: includes_license?("GNU") || includes_license?("GPL"),
              major_release: Gem::Version.new(hash["version"]) >= Gem::Version.new("1.0.0"),
              actions: [],
              sha: hash["sha"]
            }

            if File.exist?(cache_path)
              self.cache = YAML.safe_load(
                File.read(cache_path),
                permitted_classes: [Date, Time, Symbol, FastlanePluginAction],
                aliases: true
              )
            else
              self.cache = {}
            end

            if has_github_page
              is_cached = self.load_cache

              unless is_cached
                self.append_git_data
                self.append_github_data
              end
            end

            File.open(cache_path, 'w') do |file|
              file.write(self.cache.to_yaml)
            end

            self.data[:overall_score] = 0
            self.data[:ratings] = self.ratings.collect do |current_rating|
              [
                current_rating.key,
                current_rating.value
              ]
            end.to_h

            self.ratings.each do |current_rating|
              self.data[:overall_score] += current_rating.value
            end
          end

          def ratings
            [
              FastlanePluginRating.new(key: :contributors,
                               description: "The more contributors a project has, the more likely it is it stays alive",
                                     value: self.data[:github_contributors].to_i * 6),
              FastlanePluginRating.new(key: :subscribers,
                               description: "More subscribers = more popular project",
                                     value: self.data[:github_subscribers].to_i * 3),
              FastlanePluginRating.new(key: :stars,
                               description: "More stars = more popular project",
                                     value: self.data[:github_stars].to_i),
              FastlanePluginRating.new(key: :forks,
                               description: "More forks = more people seem to use/modify this project",
                                     value: self.data[:github_forks].to_i * 5),
              FastlanePluginRating.new(key: :has_mit_license,
                               description: "fastlane is MIT licensed, it's good to have plugins use MIT too",
                                     value: (self.data[:has_mit_license] ? 20 : -50)),
              FastlanePluginRating.new(key: :readme_score,
                               description: "How well is the README of the document written",
                                     value: self.data[:readme_score].to_i / 2),
              FastlanePluginRating.new(key: :age,
                               description: "Project that have been around for longer tend to be more stable",
                                     value: self.data[:age_in_days].to_i / 60),
              FastlanePluginRating.new(key: :major_release,
                               description: "Post 1.0 releases are great",
                                     value: (self.data[:major_release] ? 30 : 0)),
              FastlanePluginRating.new(key: :github_issues,
                               description: "Lots of open issues are not a good sign usually, unless the project is really popular",
                                     value: (self.data[:github_issues].to_i * -1)),
              FastlanePluginRating.new(key: :downloads,
                               description: "More downloads = more users, counted per order of magnitude so they don't outweigh everything else",
                                     value: downloads_score(self.data[:downloads])),
              FastlanePluginRating.new(key: :tests,
                               description: "The more tests a plugin has, the better",
                                     value: [self.data[:tests].to_i * 3, 80].min),
              FastlanePluginRating.new(key: :public_github_repo,
                               description: "fastlane is open source, plugins on GitHub should be public too",
                                     value: public_github_repo_score(self.data[:public_github_repo]))
            ]
          end

          # 20 points per order of magnitude (100 downloads = 40, 10k = 80), capped at 100 points from 100k downloads
          def downloads_score(count)
            [(Math.log10(count.to_i.clamp(0..) + 1) * 20).round, 100].min
          end

          # Only a GitHub repo that is private or gone is penalized, plugins hosted elsewhere are not rated
          def public_github_repo_score(public_github_repo)
            case public_github_repo
            when true then 20
            when false then -50
            else 0
            end
          end

          # What colors should the overall score be printed in
          def color_to_use
            case self.data[:overall_score]
            when -1000...40
              'ff6666'
            when 40...100
              '558000'
            when 100...250
              '63b319'
            when 250...10_000
              '72CC1D'
            else
              '558000' # this shouldn't happen
            end
          end

          def includes_license?(license)
            # e.g. "licenses"=>["MIT"],
            self.raw_hash["licenses"].any? { |l| l.include?(license) }
          end

          def load_cache
            if self.cache.key?(self.name)
              cache_data = self.cache[self.name]
            else
              cache_data = {}
            end

            self.cache[self.name] = cache_data

            if self.data[:sha] == cache_data[:sha] && cache_data[:cache_version] == CACHE_VERSION
              self.data[:initial_commit] = cache_data[:initial_commit]
              self.data[:age_in_days] = (DateTime.now - self.data[:initial_commit]).to_i
              self.data[:readme_score] = cache_data[:readme_score]
              self.data[:tests] = cache_data[:tests]
              self.data[:actions] = cache_data[:actions]
              self.data[:sha] = cache_data[:sha]

              self.data[:github_stars] = cache_data[:github_stars]
              self.data[:github_subscribers] = cache_data[:github_subscribers]
              self.data[:github_issues] = cache_data[:github_issues]
              self.data[:github_forks] = cache_data[:github_forks]
              self.data[:github_contributors] = cache_data[:github_contributors]
              self.data[:public_github_repo] = cache_data[:public_github_repo]

              return true
            end

            return false
          end

          # Everything that needs to be fetched from the content of the Git repo
          def append_git_data
            Dir.mktmpdir("fastlane-plugin") do |tmp|
              clone_folder = File.join(tmp, self.name)
              system({ "GIT_TERMINAL_PROMPT" => "0" }, "git", "clone", "--filter=blob:none", self.homepage, clone_folder)

              break unless File.directory?(clone_folder)

              Dir.chdir(clone_folder) do
                # Taken from https://github.com/CocoaPods/cocoadocs.org/blob/master/classes/stats_generator.rb
                self.data[:initial_commit] = DateTime.parse(`git rev-list --all|tail -n1|xargs git show|grep -v diff|head -n3|tail -1|cut -f2-8 -d' '`.strip).to_date
                self.data[:age_in_days] = (DateTime.now - self.data[:initial_commit]).to_i

                readme_score = 100
                if File.exist?("README.md")
                  readme_content = File.read("README.md").downcase
                  readme_score -= 50 if readme_content.include?("note to author")
                  readme_score -= 50 if readme_content.include?("todo")
                else
                  readme_score = 0
                end
                self.data[:readme_score] = readme_score

                # Detect how many tests this plugin has
                tests_count = 0
                Dir["spec/**/*_spec.rb"].each do |spec_file|
                  # poor person's way to detect the number of tests, good enough to get a sense
                  tests_count += File.read(spec_file).scan(/ it /).count
                end
                self.data[:tests] = tests_count

                actions = Dir["**/actions/*.rb"].map do |action_file|
                  FastlaneActionFileParser.new.parse_file(action_file)
                end
                # Result of the above is an array of arrays, this merges all of them into data[:actions]
                self.data[:actions] = actions.flatten

                cache_data = self.cache[self.name]

                cache_data[:initial_commit] = self.data[:initial_commit]
                cache_data[:age_in_days] = self.data[:age_in_days]
                cache_data[:readme_score] = self.data[:readme_score]
                cache_data[:tests] = self.data[:tests]
                cache_data[:actions] = self.data[:actions]
                cache_data[:sha] = self.data[:sha]
                cache_data[:cache_version] = CACHE_VERSION
              end
            end
          end

          # Everything from the GitHub API (e.g. open issues and stars)
          def append_github_data
            # e.g. https://api.github.com/repos/fastlane/fastlane
            url = self.homepage.gsub("github.com/", "api.github.com/repos/")
            url = url[0..-2] if url.end_with?("/") # what is this, 2001? We got to remove the trailing `/` otherwise GitHub will fail
            puts("Fetching #{url}")
            conn = Faraday.new(url: url) do |builder|
              # The order below IS important
              # See bug here https://github.com/lostisland/faraday_middleware/issues/105
              builder.response(:follow_redirects)
              builder.adapter(Faraday.default_adapter)
            end
            conn.headers[:authorization] = Faraday::Utils.basic_header_from(ENV["GITHUB_USER_NAME"], ENV["GITHUB_API_TOKEN"])
            response = conn.get('')
            if response.status == 404
              puts("GitHub repo not found (404) for #{self.name}: #{self.homepage}")
              self.data[:public_github_repo] = false
              return
            end
            # e.g. a rate limit (403) still has a JSON body, which must not be cached as a repo with no stars
            raise "GitHub returned #{response.status} for #{url}" unless response.success?

            repo_details = JSON.parse(response.body)
            self.data[:public_github_repo] = (repo_details["private"] == false)

            url += "/stats/contributors"
            puts("Fetching #{url}")
            conn = Faraday.new(url: url) do |builder|
              # The order below IS important
              # See bug here https://github.com/lostisland/faraday_middleware/issues/105
              builder.response(:follow_redirects)
              builder.adapter(Faraday.default_adapter)
            end

            conn.headers[:authorization] = Faraday::Utils.basic_header_from(ENV["GITHUB_USER_NAME"], ENV["GITHUB_API_TOKEN"])

            # GitHub may return 202 while it generates contributor stats, so poll until ready
            max_attempts = 12
            attempt = 1
            response = conn.get('')
            while attempt <= max_attempts && response.status == 202
              puts("Contributors stats not ready (202). Attempt #{attempt}/#{max_attempts}, retrying in 10s...")
              sleep(10)
              response = conn.get('')
              attempt += 1
            end
            raise "GitHub returned #{response.status} for #{url}" unless response.success?

            # 204 means the repo has no commits
            contributor_details = response.status == 200 ? JSON.parse(response.body) : []

            self.data[:github_stars] = repo_details["stargazers_count"].to_i
            self.data[:github_subscribers] = repo_details["subscribers_count"].to_i
            self.data[:github_issues] = repo_details["open_issues_count"].to_i
            self.data[:github_forks] = repo_details["forks_count"].to_i
            self.data[:github_contributors] = contributor_details.count

            cache_data = self.cache[self.name]

            cache_data[:github_stars] = self.data[:github_stars]
            cache_data[:github_subscribers] = self.data[:github_subscribers]
            cache_data[:github_issues] = self.data[:github_issues]
            cache_data[:github_forks] = self.data[:github_forks]
            cache_data[:github_contributors] = self.data[:github_contributors]
            cache_data[:public_github_repo] = self.data[:public_github_repo]
            # Contributor stats that never became ready are fetched again on the next run
            cache_data.delete(:cache_version) if response.status == 202
          rescue => ex
            puts("Error fetching GitHub data for #{self.name}: #{self.homepage}")
            puts(ex)
            raise ex
          end
        end

        class FastlaneActionFileParser
          attr_accessor :state

          def initialize
            self.state = []
          end

          # Parses the file to find all included actions
          # rubocop:disable Metrics/PerceivedComplexity
          def parse_file(file, debug_state: false)
            lines = File.read(file).lines
            actions = []

            # Class state information
            name = nil
            description = nil
            category = nil
            details = nil
            # Method state information
            last_method_name = nil
            last_string_statement = nil

            lines.each do |line|
              case self.state.last
              when nil
                name = action_name_from_line(line)
                self.state << :in_class if is_class?(line)
              when :in_class
                if (method_name = method_name_from_line(line))
                  last_method_name = method_name
                  self.state << :in_method
                end
                if is_end?(line)
                  self.state.pop
                  # Make sure to skip helper classes where the name is nil
                  actions << FastlanePluginAction.new(name: name.fastlane_underscore, category: category, description: description, details: details) unless name.nil?
                  name = category = description = details = nil
                end
              when :in_method
                if (string_statement = string_statement_from_line(line))
                  # Multiline support for `description` method
                  if last_method_name == 'description' && !last_string_statement.nil?
                    last_string_statement.concat(string_statement)
                  else
                    last_string_statement = string_statement
                  end
                end
                if is_block?(line)
                  self.state << :in_block
                end
                if is_end?(line)
                  category = last_string_statement if last_method_name == "category"
                  description = last_string_statement if last_method_name == "description"
                  details = last_string_statement if last_method_name == "details"
                  last_method_name = last_string_statement = nil
                  self.state.pop
                end
              when :in_block
                if is_block?(line)
                  self.state << :in_block
                end

                self.state.pop if is_end?(line)
              end
              next unless debug_state
              puts("Current line: #{line}")
              puts("Full State: #{state}")
              puts("Current action name: #{name}, category: #{category}, description: \"#{description}\", details: \"#{details}\"")
              puts("Last string statement: #{last_string_statement}, last method name: #{last_method_name}")
            end
            actions
          end

          def is_block?(line)
            # Matches beginning block statement from the list of keywords
            # `do` has to be handled separately because it can be preceded by a function call
            !!line.match(/^(?:[\s\w]*=)?\s*(if|unless|case|while|loop|for|until|begin)/) \
            || !!line.match(/^(?:[\s\w]*=)?\s*.*\s+do\s*(?:\|.*\|)?\s*(?:#.*)?$/)
          end

          def is_end?(line)
            !!line.match(/^\s*end\s*/)
          end

          def is_class?(line)
            !!line.match(/^\s*class\s+/)
          end

          def action_name_from_line(line)
            # matches `class <action name>Action < Action` and returns action_name
            line.match(/^\s*class\s+(\w+)Action\s+<\s+Action\s*(?:#.*)?$/) do |matching|
              matching.captures.first
            end
          end

          def method_name_from_line(line)
            # matches `def <method>`, strips self. if is there, returns <method>
            line.match(/^\s*def\s+(?:self\.)?(\w+)/) do |matching|
              matching.captures.first
            end
          end

          def string_statement_from_line(line)
            # All the ways ruby can represent single-line strings
            regex = [
              "[\"]([^\"]+)\"",               # Matches strings with "
              "[\']([^\']+)\'",               # Matches strings with '
              ":([@$_a-zA-Z]\\w*[!=?\\w])",   # Matches `:<symbol>`
              "%(?:[Q]?|[qs])(?:#{[           # Matches `%Q`, `%q`, `%s` and just `%`, with subexpression:
                '([\\W_])([^\\4]*)\\4',       # Matches <symbol><string><symbol>, returns <string>
                '\[([^\\]]*)\]',              # Matches [<string>]
                '\(([^\\)]*)\)',              # Matches (<string>)
                '\{([^\\]]*)\}'               # Matches {<string>}
              ].join('|')})"
            ].join('|')
            line.match(regex) do |matching|
              matching.captures.compact.last
            end
          end
        end
      end
    end
  end
end
