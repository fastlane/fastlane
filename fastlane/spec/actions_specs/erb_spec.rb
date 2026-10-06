describe Fastlane do
  describe Fastlane::FastFile do
    describe "ERB template" do
      let(:template) { File.expand_path("./fastlane/spec/fixtures/templates/dummy_html_template.erb") }
      # Not a fixed path under /tmp: parallel rspec processes share it. See fastlane#30184.
      let(:destination) { File.join(Dir.mktmpdir("fl_spec_erb"), "template.html") }

      it "generate template without placeholders" do
        result = Fastlane::FastFile.new.parse("lane :test do
          erb(
            template: '#{template}'
          )
        end").runner.execute(:test)

        expect(result).to eq("<h1></h1>\n")
      end

      it "generate template with placeholders" do
        result = Fastlane::FastFile.new.parse("lane :test do
          erb(
            template: '#{template}',
            placeholders: {
              template_name: 'ERB template name'
            }
          )
        end").runner.execute(:test)

        expect(result).to eq("<h1>ERB template name</h1>\n")
      end

      context "save to file" do
        it "generate template and save to file" do
          result = Fastlane::FastFile.new.parse("lane :test do
            erb(
              template: '#{template}',
              destination: '#{destination}',
              placeholders: {
                template_name: 'ERB template name with save'
              }
            )
          end").runner.execute(:test)

          expect(result).to eq("<h1>ERB template name with save</h1>\n")
          expect(
            File.read(destination)
          ).to eq("<h1>ERB template name with save</h1>\n")
        end

        after do
          FileUtils.remove_entry(File.dirname(destination))
        end
      end
    end
  end
end
