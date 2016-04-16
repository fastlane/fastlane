describe Fastlane do
  describe Fastlane::FastFile do
    describe "Slather Integration" do
      it "works with all parameters" do
        result = Fastlane::FastFile.new.parse("lane :test do
          slather({
            use_bundle_exec: false,
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
            proj: 'foo.xcodeproj',
            binary_basename: 'YourApp',
            binary_file: 'you',
            workspace: 'foo.xcworkspace'
          })
        end").runner.execute(:test)

        expect(result).to eq("slather coverage --build-directory foo --input-format bah --scheme Foo --buildkite --jenkins --travis --circleci --coveralls --simple-output --gutter-json --cobertura-xml --html --show --source-directory baz --output-directory 123 --binary-basename YourApp --binary-file you --ignore nothing --workspace foo.xcworkspace foo.xcodeproj")
      end

      it "works with bundle" do
        result = Fastlane::FastFile.new.parse("lane :test do
          slather({
            use_bundle_exec: true,
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
            proj: 'foo.xcodeproj',
            binary_basename: 'YourApp',
            binary_file: 'you',
            workspace: 'foo.xcworkspace'
          })
        end").runner.execute(:test)

        expect(result).to eq("bundle exec slather coverage --build-directory foo --input-format bah --scheme Foo --buildkite --jenkins --travis --circleci --coveralls --simple-output --gutter-json --cobertura-xml --html --show --source-directory baz --output-directory 123 --binary-basename YourApp --binary-file you " \
                             "--ignore nothing --workspace foo.xcworkspace foo.xcodeproj")
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

      it "works with spaces in paths" do
        result = Fastlane::FastFile.new.parse("lane :test do
          slather({
            build_directory: 'build dir',
            input_format: 'bah',
            scheme: 'Foo App',
            source_directory: 'source dir',
            output_directory: 'output dir',
            ignore: 'nothing to ignore',
            proj: 'foo bar.xcodeproj'
          })
        end").runner.execute(:test)

        expect(result).to eq("slather coverage --build-directory build\\ dir --input-format bah --scheme Foo\\ App --source-directory source\\ dir --output-directory output\\ dir --ignore nothing\\ to\\ ignore foo\\ bar.xcodeproj")
      end

      it "works with multiple ignore patterns" do
        result = Fastlane::FastFile.new.parse("lane :test do
          slather({
            ignore: ['Pods/*', '../**/*/Xcode*'],
            proj: 'foo.xcodeproj'
          })
        end").runner.execute(:test)

        expect(result).to eq("slather coverage --ignore Pods/\\* --ignore ../\\*\\*/\\*/Xcode\\* foo.xcodeproj")
      end
    end
  end
end
