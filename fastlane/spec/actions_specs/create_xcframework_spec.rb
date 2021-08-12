describe Fastlane do
  describe Fastlane::FastFile do
    describe "Create XCFramework Action" do
      before(:each) do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:directory?).and_call_original
      end

      it "requires to either provide :frameworks, :frameworks_with_dsyms, :libraries or :libraries_with_headers_or_dsyms" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            create_xcframework(
              output: 'UniversalFramework.xcframework'
            )
          end").runner.execute(:test)
        end.to raise_error("Please provide either :frameworks, :frameworks_with_dsyms, :libraries or :libraries_with_headers_or_dsyms to be packaged into the xcframework")
      end

      context "when trying to use more than one list of artifacts" do
        before(:each) do
          allow(File).to receive(:exist?).with('FrameworkA.framework').and_return(true)
          allow(File).to receive(:directory?).with('FrameworkA.framework').and_return(true)
          allow(File).to receive(:exist?).with('LibraryA.so').and_return(true)
          allow(File).to receive(:directory?).with('libraryA.so.dSYM').and_return(true)
        end

        it "forbids to provide both :frameworks and :frameworks_with_dsyms" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              create_xcframework(
                frameworks: ['FrameworkA.framework'],
                frameworks_with_dsyms: { 'FrameworkA.framework' => { dysm: 'FrameworkA.framework.dSYM' } },
                output: 'UniversalFramework.xcframework'
              )
            end").runner.execute(:test)
          end.to raise_error("Unresolved conflict between options: 'frameworks' and 'frameworks_with_dsyms'")
        end

        it "forbids to provide both :frameworks and :libraries" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              create_xcframework(
                frameworks: ['FrameworkA.framework'],
                libraries: ['LibraryA.so'],
                output: 'UniversalFramework.xcframework'
              )
            end").runner.execute(:test)
          end.to raise_error("Unresolved conflict between options: 'frameworks' and 'libraries'")
        end

        it "forbids to provide both :frameworks and :libraries_with_headers_or_dsyms" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              create_xcframework(
                frameworks: ['FrameworkA.framework'],
                libraries_with_headers_or_dsyms: { 'LibraryA.so' => { dsyms: 'libraryA.so.dSYM' } },
                output: 'UniversalFramework.xcframework'
              )
            end").runner.execute(:test)
          end.to raise_error("Unresolved conflict between options: 'frameworks' and 'libraries_with_headers_or_dsyms'")
        end

        it "forbids to provide both :frameworks_with_dsyms and :libraries" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              create_xcframework(
                frameworks_with_dsyms: { 'FrameworkA.framework' => { dysm: 'FrameworkA.framework.dSYM' } },
                libraries: ['LibraryA.so'],
                output: 'UniversalFramework.xcframework'
              )
            end").runner.execute(:test)
          end.to raise_error("Unresolved conflict between options: 'frameworks_with_dsyms' and 'libraries'")
        end

        it "forbids to provide both :frameworks_with_dsyms and :libraries_with_headers_or_dsyms" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              create_xcframework(
                frameworks_with_dsyms: { 'FrameworkA.framework' => { dysm: 'FrameworkA.framework.dSYM' } },
                libraries_with_headers_or_dsyms: { 'LibraryA.so' => { dsyms: 'libraryA.so.dSYM' } },
                output: 'UniversalFramework.xcframework'
              )
            end").runner.execute(:test)
          end.to raise_error("Unresolved conflict between options: 'frameworks_with_dsyms' and 'libraries_with_headers_or_dsyms'")
        end

        it "forbids to provide both :libraries and :libraries_with_headers_or_dsyms" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              create_xcframework(
                libraries: ['LibraryA.so'],
                libraries_with_headers_or_dsyms: { 'LibraryA.so' => { dsyms: 'libraryA.so.dSYM' } },
                output: 'UniversalFramework.xcframework'
              )
            end").runner.execute(:test)
          end.to raise_error("Unresolved conflict between options: 'libraries' and 'libraries_with_headers_or_dsyms'")
        end
      end

      context "when packaging frameworks" do
        context "which exist" do
          before(:each) do
            allow(File).to receive(:exist?).with('FrameworkA.framework').and_return(true)
            allow(File).to receive(:exist?).with('FrameworkB.framework').and_return(true)
          end

          context "and are directories" do
            before(:each) do
              allow(File).to receive(:directory?).with('FrameworkA.framework').and_return(true)
              allow(File).to receive(:directory?).with('FrameworkB.framework').and_return(true)
            end

            context "provided as an Array (without dSYMs)" do
              it "should work properly for public frameworks" do
                result = Fastlane::FastFile.new.parse("lane :test do
                  create_xcframework(
                    frameworks: ['FrameworkA.framework', 'FrameworkB.framework'],
                    output: 'UniversalFramework.xcframework'
                  )
                end").runner.execute(:test)

                expect(result).to eq('xcodebuild -create-xcframework ' \
                  + '-framework "FrameworkA.framework" -framework "FrameworkB.framework" ' \
                  + '-output "UniversalFramework.xcframework"')
              end

              it "should work properly for internal frameworks" do
                result = Fastlane::FastFile.new.parse("lane :test do
                  create_xcframework(
                    frameworks: ['FrameworkA.framework', 'FrameworkB.framework'],
                    output: 'UniversalFramework.xcframework',
                    allow_internal_distribution: true
                  )
                end").runner.execute(:test)

                expect(result).to eq('xcodebuild -create-xcframework ' \
                  + '-framework "FrameworkA.framework" -framework "FrameworkB.framework" ' \
                  + '-output "UniversalFramework.xcframework" ' \
                  + '-allow-internal-distribution')
              end
            end

            context "provided as a Hash (with dSYMs)" do
              context "which dSYM is a directory" do
                before(:each) do
                  allow(File).to receive(:directory?).with('FrameworkB.framework.dSYM').and_return(true)
                end

                it "should work properly for public frameworks" do
                  result = Fastlane::FastFile.new.parse("lane :test do
                    create_xcframework(
                      frameworks_with_dsyms: {'FrameworkA.framework' => {}, 'FrameworkB.framework' => { dsyms: 'FrameworkB.framework.dSYM' } },
                      output: 'UniversalFramework.xcframework'
                    )
                  end").runner.execute(:test)

                  expect(result).to eq('xcodebuild -create-xcframework ' \
                    + '-framework "FrameworkA.framework" -framework "FrameworkB.framework" -debug-symbols "FrameworkB.framework.dSYM" ' \
                    + '-output "UniversalFramework.xcframework"')
                end

                it "should work properly for internal frameworks" do
                  result = Fastlane::FastFile.new.parse("lane :test do
                    create_xcframework(
                      frameworks_with_dsyms: {'FrameworkA.framework' => {}, 'FrameworkB.framework' => { dsyms: 'FrameworkB.framework.dSYM' } },
                      output: 'UniversalFramework.xcframework',
                      allow_internal_distribution: true
                    )
                  end").runner.execute(:test)

                  expect(result).to eq('xcodebuild -create-xcframework ' \
                    + '-framework "FrameworkA.framework" -framework "FrameworkB.framework" -debug-symbols "FrameworkB.framework.dSYM" ' \
                    + '-output "UniversalFramework.xcframework" ' \
                    + '-allow-internal-distribution')
                end
              end

              context "which dSYM is not a directory" do
                it "should fail due to wrong dSYM directory" do
                  expect do
                    Fastlane::FastFile.new.parse("lane :test do
                      create_xcframework(
                        frameworks_with_dsyms: {'FrameworkA.framework' => {}, 'FrameworkB.framework' => { dsyms: 'FrameworkB.framework.dSYM' } },
                        output: 'UniversalFramework.xcframework'
                      )
                    end").runner.execute(:test)
                  end.to raise_error("FrameworkB.framework.dSYM doesn't seem to be a dSYM archive")
                end
              end
            end
          end

          context "and are not directories" do
            it "should fail due to wrong framework when provided as an Array" do
              expect do
                Fastlane::FastFile.new.parse("lane :test do
                  create_xcframework(
                    frameworks: ['FrameworkA.framework', 'FrameworkB.framework'],
                    output: 'UniversalFramework.xcframework'
                  )
                end").runner.execute(:test)
              end.to raise_error("FrameworkA.framework doesn't seem to be a framework")
            end

            it "should fail due to wrong framework when provided as a Hash" do
              expect do
                Fastlane::FastFile.new.parse("lane :test do
                  create_xcframework(
                    frameworks_with_dsyms: {'FrameworkA.framework' => {}, 'FrameworkB.framework' => { dsyms: 'FrameworkB.framework.dSYM' } },
                    output: 'UniversalFramework.xcframework'
                  )
                end").runner.execute(:test)
              end.to raise_error("FrameworkA.framework doesn't seem to be a framework")
            end
          end
        end

        context "which don't exist" do
          it "should fail due to missing framework" do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                create_xcframework(
                  frameworks: ['FrameworkA.framework', 'FrameworkB.framework'],
                  output: 'UniversalFramework.xcframework'
                )
              end").runner.execute(:test)
            end.to raise_error("Couldn't find framework at FrameworkA.framework")
          end
        end
      end

      context "when rewriting existing xcframework" do
        before(:each) do
          allow(File).to receive(:exist?).with('FrameworkA.framework').and_return(true)
          allow(File).to receive(:exist?).with('FrameworkB.framework').and_return(true)
          allow(File).to receive(:directory?).with('FrameworkA.framework').and_return(true)
          allow(File).to receive(:directory?).with('FrameworkB.framework').and_return(true)
          allow(File).to receive(:directory?).with('UniversalFramework.xcframework').and_return(true)
        end

        it "should delete the existing xcframework" do
          expect(FileUtils).to receive(:remove_dir).with('UniversalFramework.xcframework')

          Fastlane::FastFile.new.parse("lane :test do
            create_xcframework(
              frameworks: ['FrameworkA.framework', 'FrameworkB.framework'],
              output: 'UniversalFramework.xcframework'
            )
          end").runner.execute(:test)
        end
      end

      context "when packaging libraries" do
        context "which exist" do
          before(:each) do
            allow(File).to receive(:exist?).with('LibraryA.so').and_return(true)
            allow(File).to receive(:exist?).with('LibraryB.so').and_return(true)
          end

          context "provided as an Array (without headers or dSYMs)" do
            it "should work properly for public frameworks" do
              result = Fastlane::FastFile.new.parse("lane :test do
                create_xcframework(
                  libraries: ['LibraryA.so', 'LibraryB.so'],
                  output: 'UniversalFramework.xcframework'
                )
              end").runner.execute(:test)

              expect(result).to eq('xcodebuild -create-xcframework ' \
                + '-library "LibraryA.so" -library "LibraryB.so" ' \
                + '-output "UniversalFramework.xcframework"')
            end

            it "should work properly for internal frameworks" do
              result = Fastlane::FastFile.new.parse("lane :test do
                create_xcframework(
                  libraries: ['LibraryA.so', 'LibraryB.so'],
                  output: 'UniversalFramework.xcframework',
                  allow_internal_distribution: true
                )
              end").runner.execute(:test)

              expect(result).to eq('xcodebuild -create-xcframework ' \
                + '-library "LibraryA.so" -library "LibraryB.so" ' \
                + '-output "UniversalFramework.xcframework" ' \
                + '-allow-internal-distribution')
            end
          end

          context "provided as a Hash (with headers or dSYMs)" do
            context "which headers and dSYMs are a directory" do
              before(:each) do
                allow(File).to receive(:directory?).with('libraryA.so.dSYM').and_return(true)
                allow(File).to receive(:directory?).with('headers').and_return(true)
              end

              it "should work properly for public frameworks" do
                result = Fastlane::FastFile.new.parse("lane :test do
                  create_xcframework(
                    libraries_with_headers_or_dsyms: { 'LibraryA.so' => { dsyms: 'libraryA.so.dSYM' }, 'LibraryB.so' => { headers: 'headers' } },
                    output: 'UniversalFramework.xcframework'
                  )
                end").runner.execute(:test)

                expect(result).to eq('xcodebuild -create-xcframework ' \
                  + '-library "LibraryA.so" -debug-symbols "libraryA.so.dSYM" -library "LibraryB.so" -headers "headers" ' \
                  + '-output "UniversalFramework.xcframework"')
              end

              it "should work properly for internal frameworks" do
                result = Fastlane::FastFile.new.parse("lane :test do
                  create_xcframework(
                    libraries_with_headers_or_dsyms: { 'LibraryA.so' => { dsyms: 'libraryA.so.dSYM' }, 'LibraryB.so' => { headers: 'headers' } },
                    output: 'UniversalFramework.xcframework',
                    allow_internal_distribution: true
                  )
                end").runner.execute(:test)

                expect(result).to eq('xcodebuild -create-xcframework ' \
                  + '-library "LibraryA.so" -debug-symbols "libraryA.so.dSYM" -library "LibraryB.so" -headers "headers" ' \
                  + '-output "UniversalFramework.xcframework" ' \
                  + '-allow-internal-distribution')
              end
            end

            context "which headers is not a directory" do
              before(:each) do
                allow(File).to receive(:directory?).with('libraryA.so.dSYM').and_return(true)
              end

              it "should fail due to wrong headers directory" do
                expect do
                  Fastlane::FastFile.new.parse("lane :test do
                    create_xcframework(
                      libraries_with_headers_or_dsyms: { 'LibraryA.so' => { dsyms: 'libraryA.so.dSYM' }, 'LibraryB.so' => { headers: 'headers' } },
                      output: 'UniversalFramework.xcframework'
                    )
                  end").runner.execute(:test)
                end.to raise_error("headers doesn't exist or is not a directory")
              end
            end

            context "which dSYMs is not a directory" do
              before(:each) do
                allow(File).to receive(:directory?).with('headers').and_return(true)
              end

              it "should fail due to wrong dSYM directory" do
                expect do
                  Fastlane::FastFile.new.parse("lane :test do
                    create_xcframework(
                      libraries_with_headers_or_dsyms: { 'LibraryA.so' => { dsyms: 'libraryA.so.dSYM' }, 'LibraryB.so' => { headers: 'headers' } },
                      output: 'UniversalFramework.xcframework'
                    )
                  end").runner.execute(:test)
                end.to raise_error("libraryA.so.dSYM doesn't seem to be a dSYM archive")
              end
            end
          end
        end

        context "which don't exist" do
          it "should fail due to missing library" do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                create_xcframework(
                  libraries: ['LibraryA.so', 'LibraryB.so'],
                  output: 'UniversalFramework.xcframework'
                )
              end").runner.execute(:test)
            end.to raise_error("Couldn't find library at LibraryA.so")
          end
        end
      end
    end
  end
end
