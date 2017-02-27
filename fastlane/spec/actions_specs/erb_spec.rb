describe Fastlane do
  describe Fastlane::FastFile do
    describe "ERB template" do
      let(:template) { File.expand_path("./fastlane/spec/fixtures/templates/dummy_html_template.erb") }
      let(:destination) { "/tmp/fastlane/template.html" }

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
        before do
          FileUtils.mkdir_p(File.dirname(destination))
        end

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
          File.delete(destination)
        end
      end
    end
  end
end
