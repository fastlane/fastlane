RSpec::Matchers.define(:shell_command) do |x|
  match { |actual|
    Fastlane::Actions.shell_command_from_args(*actual) == x
  }
end

describe Fastlane do
  describe Fastlane::FastFile do
    before do
      allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
      @path = "./fastlane/spec/fixtures/actions/archive.rb"
      @output_path_with_zip = "./fastlane/spec/fixtures/actions/archive_file.zip"
      @output_path_without_zip = "./fastlane/spec/fixtures/actions/archive_file"
    end

    describe "zip" do
      it "generates a valid zip command" do
        expect(Fastlane::Actions).to receive(:sh).with(shell_command("zip -r #{File.expand_path(@path)}.zip archive.rb"))

        result = Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{@path}')
        end").runner.execute(:test)
      end

      it "generates a valid zip command without verbose output" do
        expect(Fastlane::Actions).to receive(:sh).with(shell_command("zip -rq #{File.expand_path(@path)}.zip archive.rb"))

        result = Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{@path}', verbose: false)
        end").runner.execute(:test)
      end

      it "generates an output path given no output path" do
        result = Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{@path}', output_path: '#{@path}')
        end").runner.execute(:test)

        expect(result).to eq(File.absolute_path("#{@path}.zip"))
      end

      it "generates an output path with zip extension (given zip extension)" do
        result = Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{@path}', output_path: '#{@output_path_with_zip}')
        end").runner.execute(:test)

        expect(result).to eq(File.absolute_path(@output_path_with_zip))
      end

      it "generates an output path with zip extension (not given zip extension)" do
        result = Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{@path}', output_path: '#{@output_path_without_zip}')
        end").runner.execute(:test)

        expect(result).to eq(File.absolute_path(@output_path_with_zip))
      end

      it "encrypts the contents of the zip archive using a password" do
        password = "5O#RUKp0Zgop"
        expect(Fastlane::Actions).to receive(:sh).with(shell_command("zip -rq -P '#{password}' #{File.expand_path(@path)}.zip archive.rb"))

        result = Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{@path}', verbose: false, password: '#{password}')
        end").runner.execute(:test)
      end
    end
  end
end
