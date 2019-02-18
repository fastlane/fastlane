describe Fastlane do
  describe Fastlane::FastFile do
    describe "Create keychain Integration" do
      it "works with name and password" do
        keychain_password = "testpassword"
        keychain_name = "test.keychain"
        keychain_path = "~/Library/Keychains/#{keychain_name}"
        result = Fastlane::FastFile.new.parse("lane :test do
          create_keychain ({
            name: '#{keychain_name}',
            password: '#{keychain_password}',
          })
        end").runner.execute(:test)

        expect(result.size).to eq(3)
        expect(result[0]).to eq("security create-keychain -p #{keychain_password.shellescape} #{keychain_path.shellescape}")
        expect(result[1]).to start_with("security set-keychain-settings")
        expect(result[1]).to include("-t 300")
        expect(result[1]).to_not(include("-l"))
        expect(result[1]).to_not(include("-u"))
        expect(result[1]).to include(keychain_path.to_s)
        expect(result[2]).to start_with("security list-keychains -s")
        expect(result[2]).to end_with(File.expand_path(keychain_path.to_s).shellescape.to_s)
      end

      it "works with name and password that contain spaces or `\"`" do
        keychain_password = "\"test password\""
        keychain_name = "test.keychain"
        keychain_path = "~/Library/Keychains/#{keychain_name}"
        result = Fastlane::FastFile.new.parse("lane :test do
          create_keychain ({
            name: '#{keychain_name}',
            password: '#{keychain_password}',
          })
        end").runner.execute(:test)

        expect(result.size).to eq(3)
        expect(result[0]).to eq("security create-keychain -p #{keychain_password.shellescape} #{keychain_path.shellescape}")
      end

      it "works with keychain-settings and name and password" do
        keychain_password = "testpassword"
        keychain_name = "test.keychain"
        keychain_path = "~/Library/Keychains/#{keychain_name}"
        result = Fastlane::FastFile.new.parse("lane :test do
          create_keychain ({
            name: '#{keychain_name}',
            password: '#{keychain_password}',
            timeout: 600,
            lock_when_sleeps: true,
            lock_after_timeout: true,
          })
        end").runner.execute(:test)

        expect(result.size).to eq(3)
        expect(result[0]).to eq("security create-keychain -p #{keychain_password.shellescape} #{keychain_path.shellescape}")

        expect(result[1]).to start_with("security set-keychain-settings")
        expect(result[1]).to include("-t 600")
        expect(result[1]).to include("-l")
        expect(result[1]).to include("-u")
        expect(result[1]).to include(keychain_path.shellescape.to_s)
      end

      it "works with default_keychain and name and password" do
        keychain_password = "testpassword"
        keychain_name = "test.keychain"
        keychain_path = "~/Library/Keychains/#{keychain_name}"
        result = Fastlane::FastFile.new.parse("lane :test do
          create_keychain ({
            name: '#{keychain_name}',
            password: '#{keychain_password}',
            default_keychain: true,
          })
        end").runner.execute(:test)

        expect(result.size).to eq(4)
        expect(result[0]).to eq("security create-keychain -p #{keychain_password.shellescape} #{keychain_path.shellescape}")

        expect(result[1]).to eq("security default-keychain -s #{keychain_path.shellescape}")

        expect(result[2]).to start_with("security set-keychain-settings")
        expect(result[2]).to include("-t 300")
        expect(result[2]).to_not(include("-l"))
        expect(result[2]).to_not(include("-u"))
        expect(result[2]).to include(keychain_path.shellescape.to_s)
      end

      it "works with unlock and name and password" do
        keychain_password = "testpassword"
        keychain_name = "test.keychain"
        keychain_path = "~/Library/Keychains/#{keychain_name}"
        result = Fastlane::FastFile.new.parse("lane :test do
          create_keychain ({
            name: '#{keychain_name}',
            password: '#{keychain_password}',
            unlock: true,
          })
        end").runner.execute(:test)

        expect(result.size).to eq(4)
        expect(result[0]).to eq("security create-keychain -p #{keychain_password.shellescape} #{keychain_path.shellescape}")

        expect(result[1]).to eq("security unlock-keychain -p #{keychain_password.shellescape} #{keychain_path.shellescape}")

        expect(result[2]).to start_with("security set-keychain-settings")
        expect(result[2]).to include("-t 300")
        expect(result[2]).to_not(include("-l"))
        expect(result[2]).to_not(include("-u"))
        expect(result[2]).to include(keychain_path.shellescape.to_s)
      end

      it "works with :path param" do
        keychain_password = "testpassword"
        keychain_name = "test.keychain"
        keychain_path = "/tmp/#{keychain_name}"
        result = Fastlane::FastFile.new.parse("lane :test do
          create_keychain ({
            path: '#{keychain_path}',
            password: '#{keychain_password}',
            default_keychain: true,
            unlock: true,
            timeout: 600,
            lock_when_sleeps: true,
            lock_after_timeout: true,
            add_to_search_list: false,
          })
        end").runner.execute(:test)
        expect(result.size).to eq(4)
        expect(result[0]).to eq("security create-keychain -p #{keychain_password.shellescape} #{keychain_path.shellescape}")

        expect(result[1]).to eq("security default-keychain -s #{keychain_path.shellescape}")
        expect(result[2]).to eq("security unlock-keychain -p #{keychain_password.shellescape} #{keychain_path.shellescape}")

        expect(result[3]).to start_with("security set-keychain-settings")
        expect(result[3]).to include("-t 600")
        expect(result[3]).to include("-l")
        expect(result[3]).to include("-u")
        expect(result[3]).to include(keychain_path.shellescape.to_s)
      end

      it "works with all params" do
        keychain_password = "testpassword"
        keychain_name = "test.keychain"
        keychain_path = "~/Library/Keychains/#{keychain_name}"
        result = Fastlane::FastFile.new.parse("lane :test do
          create_keychain ({
            name: '#{keychain_name}',
            password: '#{keychain_password}',
            default_keychain: true,
            unlock: true,
            timeout: 600,
            lock_when_sleeps: true,
            lock_after_timeout: true,
            add_to_search_list: false,
          })
        end").runner.execute(:test)

        expect(result.size).to eq(4)
        expect(result[0]).to eq("security create-keychain -p #{keychain_password.shellescape} #{keychain_path.shellescape}")

        expect(result[1]).to eq("security default-keychain -s #{keychain_path.shellescape}")
        expect(result[2]).to eq("security unlock-keychain -p #{keychain_password.shellescape} #{keychain_path.shellescape}")

        expect(result[3]).to start_with("security set-keychain-settings")
        expect(result[3]).to include("-t 600")
        expect(result[3]).to include("-l")
        expect(result[3]).to include("-u")
        expect(result[3]).to include(keychain_path.shellescape.to_s)
      end
    end
  end
end
