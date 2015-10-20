describe Fastlane do
  describe Fastlane::FastFile do
    describe "Slather Integration" do
      it "works with all parameters" do
        result = Fastlane::FastFile.new.parse("lane :test do
          slather({
            build_directory: 'foo',
            input_format: 'bah',
            scheme: 'Foo',
            buildkite: true,
            jenkins: true,
            travis: true,
            circleci: true,
            coveralls: true,
            simple_output: true,
            gutter_json: true,
            cobertura_xml: true,
            html: true,
            show: true,
            source_directory: 'baz',
            output_directory: '123',
            ignore: 'nothing',
            proj: 'foo.xcodeproj'
          })
        end").runner.execute(:test)

        expect(result).to eq("slather coverage  --build-directory foo --input-format bah --scheme Foo --buildkite --jenkins --travis --circleci --coveralls --simple-output --gutter-json --cobertura-xml --html --show --source-directory baz --output-directory 123 --ignore nothing foo.xcodeproj")
      end

      it "requires project to be specified" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            slather({})
          end").runner.execute(:test)
        end.to raise_error
      end

      it "does not require any parameters other than project" do
        expect do
          result = Fastlane::FastFile.new.parse("lane :test do
            slather({
              proj: 'foo.xcodeproj'
            })
          end").runner.execute(:test)

          expect(result).to eq("slather coverage foo.xcodeproj")
        end
      end
    end
  end
end
