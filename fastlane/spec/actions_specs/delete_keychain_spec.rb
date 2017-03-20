describe Fastlane do
  describe Fastlane::FastFile do
    describe "Delete keychain Integration" do
      before :each do
        allow(File).to receive(:exist?).and_return(false)
      end

      # Run this series of tests for each possible input option that we accept
      ['name', 'keychain_path'].each do |option_name|
        describe "using the #{option_name} option" do
          # Use a variety of keychain naming styles - an absolute path is handled separately below
          ['.keychain', '.keychain-db', '-db', ''].each do |suffix|
            name = 'test' + suffix
            description = suffix.empty? ? 'undecorated' : suffix

            describe "with a #{description} keychain name" do
              # Ensure that we can find it in each of the possible keychain locations
              FastlaneCore::Helper.possible_keychain_paths(name).each do |location|
                it "can find it in #{location}" do
                  allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
                  allow(File).to receive(:exist?).with(location).and_return(true)

                  result = Fastlane::FastFile.new.parse("lane :test do
                    delete_keychain ({
                      #{option_name}: '#{name}'
                    })
                  end").runner.execute(:test)

                  expect(result).to eq("security delete-keychain #{location.shellescape}")
                end
              end
            end
          end

          describe "with an absolute path" do
            name = File.expand_path('test')

            # Ensure that we can find it in each of the possible keychain locations
            FastlaneCore::Helper.possible_keychain_paths(name).each do |location|
              it "can find it in #{location}" do
                allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
                allow(File).to receive(:exist?).with(location).and_return(true)

                result = Fastlane::FastFile.new.parse("lane :test do
                  delete_keychain ({
                    #{option_name}: '#{name}'
                  })
                end").runner.execute(:test)

                expect(result).to eq("security delete-keychain #{location.shellescape}")
              end
            end
          end
        end
      end

      it "works with keychain name that contain spaces and `\"`" do
        keychain = File.expand_path('" test ".keychain')

        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        allow(File).to receive(:exist?).with(keychain).and_return(true)

        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: '\" test \".keychain'
          })
        end").runner.execute(:test)

        expect(result).to eq %(security delete-keychain #{keychain.shellescape})
      end

      it "shows an error message if the keychain can't be found" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            delete_keychain ({
              name: 'test.keychain'
            })
          end").runner.execute(:test)
        end.to raise_error(
          "Could not locate the provided keychain. Tried:" \
          "\n\t#{File.expand_path('~/Library/Keychains/test-db')}" \
          "\n\t#{File.expand_path('~/Library/Keychains/test.keychain-db')}" \
          "\n\t#{File.expand_path('~/Library/Keychains/test')}" \
          "\n\t#{File.expand_path('~/Library/Keychains/test.keychain')}" \
          "\n\t#{File.expand_path('test-db')}" \
          "\n\t#{File.expand_path('test.keychain-db')}" \
          "\n\t#{File.expand_path('test')}" \
          "\n\t#{File.expand_path('test.keychain')}"
        )
      end

      it "shows an error message if neither :name nor :keychain_path is given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            delete_keychain
          end").runner.execute(:test)
        end.to raise_error('You either have to set :name or :keychain_path')
      end
    end
  end
end
