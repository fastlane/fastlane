describe Fastlane do
  describe Fastlane::FastFile do
    describe "CLOC Integration" do
      it "does run cloc using only default options" do
        result = Fastlane::FastFile.new.parse("lane :test do
            cloc
          end").runner.execute(:test)

        expect(result).to eq("/usr/local/bin/cloc  --by-file --xml  --out=build/cloc.xml")
      end

      it 'does set the exclude directories' do
        result = Fastlane::FastFile.new.parse("lane :test do
            cloc(exclude_dir: 'test1,test2,build')
          end").runner.execute(:test)

        expect(result).to eq("/usr/local/bin/cloc --exclude-dir=test1,test2,build --by-file --xml  --out=build/cloc.xml")
      end

      it 'does set the output directory' do
        result = Fastlane::FastFile.new.parse("lane :test do
            cloc(output_directory: '/tmp')
          end").runner.execute(:test)

        expect(result).to eq("/usr/local/bin/cloc  --by-file --xml  --out=/tmp/cloc.xml")
      end

      it 'does set the source directory' do
        result = Fastlane::FastFile.new.parse("lane :test do
            cloc(source_directory: 'MyCoolApp')
          end").runner.execute(:test)

        expect(result).to eq("/usr/local/bin/cloc  --by-file --xml  --out=build/cloc.xml MyCoolApp")
      end

      it 'does switch to plain text when xml is toggled off' do
        result = Fastlane::FastFile.new.parse("lane :test do
            cloc(xml: false)
          end").runner.execute(:test)

        expect(result).to eq("/usr/local/bin/cloc  --by-file  --out=build/cloc.txt")
      end
    end
  end
end
