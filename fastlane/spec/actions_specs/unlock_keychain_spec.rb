describe Fastlane do
  describe Fastlane::FastFile do
    describe "Unlock keychain Integration" do
      it "works with path and password and existing keychain" do
        keychain_path = Tempfile.new('foo').path

        result = Fastlane::FastFile.new.parse("lane :test do
          unlock_keychain ({
            path: '#{keychain_path}',
            password: 'testpassword'
          })
        end").runner.execute(:test)

        expect(result.size).to eq(3)
        expect(result[0]).to start_with("security list-keychains -s")
        expect(result[0]).to end_with(keychain_path)
        expect(result[1]).to eq("security unlock-keychain -p testpassword #{keychain_path}")
        expect(result[2]).to eq("security set-keychain-settings #{keychain_path}")
      end

      it "doesn't add keychain to search list" do
        keychain_path = Tempfile.new('foo').path

        result = Fastlane::FastFile.new.parse("lane :test do
          unlock_keychain ({
            path: '#{keychain_path}',
            password: 'testpassword',
            add_to_search_list: false,
          })
        end").runner.execute(:test)

        expect(result.size).to eq(2)
        expect(result[0]).to eq("security unlock-keychain -p testpassword #{keychain_path}")
        expect(result[1]).to eq("security set-keychain-settings #{keychain_path}")
      end

      it "replace keychain in search list" do
        keychain_path = Tempfile.new('foo').path

        result = Fastlane::FastFile.new.parse("lane :test do
          unlock_keychain ({
            path: '#{keychain_path}',
            password: 'testpassword',
            add_to_search_list: :replace,
          })
        end").runner.execute(:test)

        expect(result.size).to eq(3)
        expect(result[0]).to eq("security list-keychains -s #{keychain_path}")
        expect(result[1]).to eq("security unlock-keychain -p testpassword #{keychain_path}")
        expect(result[2]).to eq("security set-keychain-settings #{keychain_path}")
      end

      it "set default keychain" do
        keychain_path = Tempfile.new('foo').path

        result = Fastlane::FastFile.new.parse("lane :test do
          unlock_keychain ({
            path: '#{keychain_path}',
            password: 'testpassword',
            set_default: true,
          })
        end").runner.execute(:test)

        expect(result.size).to eq(4)
        expect(result[0]).to start_with("security list-keychains -s")
        expect(result[0]).to end_with(keychain_path)
        expect(result[1]).to eq("security default-keychain -s #{keychain_path}")
        expect(result[2]).to eq("security unlock-keychain -p testpassword #{keychain_path}")
        expect(result[3]).to eq("security set-keychain-settings #{keychain_path}")
      end
    end
  end
end
