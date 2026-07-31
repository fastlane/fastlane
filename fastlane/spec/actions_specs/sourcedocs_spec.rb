describe Fastlane do
  describe Fastlane::FastFile do
    describe "SourceDocs" do
      context "when specify output path" do
        it "default use case" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs'
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs")
        end
      end

      context "when specify all_modules option" do
        it "doesn't add all_modules option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              all_modules: false,
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs")
        end

        it "adds all_modules option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              all_modules: true
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --all-modules --output-folder docs")
        end
      end

      context "when specify spm_module option" do
        it "doesn't add spm_module option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs")
        end

        it "adds spm_module option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              spm_module: 'MySpmModule'
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --spm-module MySpmModule --output-folder docs")
        end
      end

      context "when specify module_name option" do
        it "doesn't add module_name option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs")
        end

        it "adds module_name option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              module_name: 'MyModule'
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --module-name MyModule --output-folder docs")
        end
      end

      context "when specify link_beginning option" do
        it "doesn't add link_beginning option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs")
        end

        it "adds link_beginning option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              link_beginning: 'sdk'
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --link-beginning sdk --output-folder docs")
        end
      end

      context "when specify link_ending option" do
        it "doesn't add link_ending option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs")
        end

        it "adds link_ending option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              link_ending: '.md'
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --link-ending .md --output-folder docs")
        end
      end

      context "when specify min_acl option" do
        it "doesn't add min_acl option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs")
        end

        it "adds min_acl option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              min_acl: 'internal'
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs --min-acl internal")
        end
      end

      context "when specify module_name_path option" do
        it "doesn't add module_name_path option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              module_name_path: false,
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs")
        end

        it "adds module_name_path option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              module_name_path: true
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs --module-name-path")
        end
      end

      context "when specify clean option" do
        it "doesn't add clean option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              clean: false,
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs")
        end

        it "adds clean option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              clean: true
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs --clean")
        end
      end

      context "when specify collapsible option" do
        it "adds collapsible option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              collapsible: true
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs --collapsible")
        end

        it "doesn't add collapsible option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              collapsible: false
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs")
        end
      end
      context "when specify table_of_contents option" do
        it "adds table_of_contents option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              table_of_contents: true
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs --table-of-contents")
        end

        it "doesn't add table-of-contents option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              table_of_contents: false
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs")
        end
      end

      context "when specify reproducible option" do
        it "adds reproducible option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              reproducible: true
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs --reproducible-docs")
        end

        it "doesn't add reproducible option" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              reproducible: false
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs")
        end
      end

      context "when specify scheme parameter" do
        it "adds scheme parameter" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              scheme: 'MyApp'
            )
            end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs -- -scheme MyApp")
        end

        it "adds sdk platform parameter" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              scheme: 'MyApp',
              sdk_platform: 'iphoneos'
            )
            end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs -- -scheme MyApp -sdk iphoneos")
        end
      end

      context "when scheme parameter not specified" do
        it "adds no scheme parameter" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
            )
            end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs")
        end

        it "adds no sdk platform parameter" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              output_folder: 'docs',
              sdk_platform: 'iphoneos'
            )
            end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs")
        end
      end

      context "when specify lots parameters" do
        it "adds lots parameters" do
          result = Fastlane::FastFile.new.parse("lane :test do
            sourcedocs(
              sdk_platform: 'macosx',
              output_folder: 'docs',
              collapsible: true,
              table_of_contents: true,
              clean: true,
              reproducible: true,
              module_name_path: true,
              scheme: 'MyApp',
              min_acl: 'internal'
            )
          end").runner.execute(:test)

          expect(result).to eq("sourcedocs generate --output-folder docs --min-acl internal --module-name-path --clean --collapsible --table-of-contents --reproducible-docs -- -scheme MyApp -sdk macosx")
        end
      end
    end
  end
end
