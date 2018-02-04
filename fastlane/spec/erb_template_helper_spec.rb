describe Fastlane do
  describe Fastlane::ErbTemplateHelper do
    describe ".load_template" do
      it "raises an error if file does not exist" do
        expect do
          Fastlane::ErbTemplateHelper.load('invalid_name')
        end.to raise_exception("Could not find template at path '#{Fastlane::ROOT}/lib/assets/invalid_name.erb'")
      end

      it "should load file if exists" do
        f = Fastlane::ErbTemplateHelper.load('s3_html_template')
        expect(f).not_to(be_empty)
      end
    end

    describe "#render_template" do
      before do
        @template = File.read("./fastlane/spec/fixtures/templates/dummy_html_template.erb")
      end

      it "return true if it's a platform" do
        rendered_template = Fastlane::ErbTemplateHelper.render(@template, {
          template_name: "name"
        }).delete!("\n")
        expect(rendered_template).to eq("<h1>name</h1>")
      end
    end
  end
end
