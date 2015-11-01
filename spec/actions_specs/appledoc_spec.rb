describe Fastlane do
  describe Fastlane::FastFile do
    describe "Clean Cocoapods Cache Integration" do
      it "default use case" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc \"input/dir\"")
      end

      it "adds output param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            output: '~/Desktop'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --output \"~/Desktop\" \"input/dir\"")
      end

      it "adds templates param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            templates: 'path/to/templates'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --templates \"path/to/templates\" \"input/dir\"")
      end

      it "adds docset_install_path param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_install_path: 'docs/install/path'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-install-path \"docs/install/path\" \"input/dir\"")
      end

      it "adds include param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            include: 'path/to/include'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --include \"path/to/include\" \"input/dir\"")
      end

      it "adds ignore param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            ignore: 'ignored/path'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --ignore \"ignored/path\" \"input/dir\"")
      end

      it "adds exclude_output param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            exclude_output: 'excluded/path'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --exclude-output \"excluded/path\" \"input/dir\"")
      end

      it "adds index_desc param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            index_desc: 'index_desc/path'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --index-desc \"index_desc/path\" \"input/dir\"")
      end

      it "adds project_name param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            project_name: 'PROJECT NAME'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --project-name \"PROJECT NAME\" \"input/dir\"")
      end

      it "adds project_version param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            project_version: 'VERSION'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --project-version \"VERSION\" \"input/dir\"")
      end

      it "adds project_company param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            project_company: 'COMPANY'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --project-company \"COMPANY\" \"input/dir\"")
      end

      it "adds company_id param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            company_id: 'COMPANY ID'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --company-id \"COMPANY ID\" \"input/dir\"")
      end

      it "adds create_html param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            create_html: true
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --create-html \"input/dir\"")
      end

      it "adds create_docset param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            create_docset: true
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --create-docset \"input/dir\"")
      end

      it "adds install_docset param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            install_docset: true
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --install-docset \"input/dir\"")
      end

      it "adds publish_docset param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            publish_docset: true
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --publish-docset \"input/dir\"")
      end

      it "adds html_anchors param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            html_anchors: 'some anchors'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --html-anchors \"some anchors\" \"input/dir\"")
      end

      it "adds clean_output param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            clean_output: true
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --clean-output \"input/dir\"")
      end

      it "adds docset_bundle_id param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_bundle_id: 'com.bundle.id'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-bundle-id \"com.bundle.id\" \"input/dir\"")
      end

      it "adds docset_bundle_name param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_bundle_name: 'Bundle name'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-bundle-name \"Bundle name\" \"input/dir\"")
      end

      it "adds docset_desc param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_desc: 'DocSet description'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-desc \"DocSet description\" \"input/dir\"")
      end

      it "adds docset_copyright param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_copyright: 'DocSet copyright'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-copyright \"DocSet copyright\" \"input/dir\"")
      end

      it "adds docset_feed_name param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_feed_name: 'DocSet feed name'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-feed-name \"DocSet feed name\" \"input/dir\"")
      end

      it "adds docset_feed_url param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_feed_url: 'http://docset-feed-url.com'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-feed-url \"http://docset-feed-url.com\" \"input/dir\"")
      end

      it "adds docset_feed_formats param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_feed_formats: 'atom'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-feed-formats \"atom\" \"input/dir\"")
      end

      it "adds docset_package_url param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_package_url: 'http://docset-package-url.com'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-package-url \"http://docset-package-url.com\" \"input/dir\"")
      end

      it "adds docset_fallback_url param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_fallback_url: 'http://docset-fallback-url.com'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-fallback-url \"http://docset-fallback-url.com\" \"input/dir\"")
      end

      it "adds docset_publisher_id param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_publisher_id: 'Publisher ID'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-publisher-id \"Publisher ID\" \"input/dir\"")
      end

      it "adds docset_publisher_name param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_publisher_name: 'Publisher name'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-publisher-name \"Publisher name\" \"input/dir\"")
      end

      it "adds docset_min_xcode_version param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_min_xcode_version: '6.4'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-min-xcode-version \"6.4\" \"input/dir\"")
      end

      it "adds docset_platform_family param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_platform_family: 'ios'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-platform-family \"ios\" \"input/dir\"")
      end

      it "adds docset_cert_issuer param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_cert_issuer: 'Some issuer'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-cert-issuer \"Some issuer\" \"input/dir\"")
      end

      it "adds docset_cert_signer param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_cert_signer: 'Some signer'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-cert-signer \"Some signer\" \"input/dir\"")
      end

      it "adds docset_bundle_filename param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_bundle_filename: 'DocSet bundle filename'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-bundle-filename \"DocSet bundle filename\" \"input/dir\"")
      end

      it "adds docset_atom_filename param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_atom_filename: 'DocSet atom feed filename'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-atom-filename \"DocSet atom feed filename\" \"input/dir\"")
      end

      it "adds docset_xml_filename param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_xml_filename: 'DocSet xml feed filename'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-xml-filename \"DocSet xml feed filename\" \"input/dir\"")
      end

      it "adds docset_package_filename param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docset_package_filename: 'DocSet package filename'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docset-package-filename \"DocSet package filename\" \"input/dir\"")
      end

      it "adds options param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            options: '--use-single-star --keep-intermediate-files --search-undocumented-doc'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --use-single-star --keep-intermediate-files --search-undocumented-doc \"input/dir\"")
      end

      it "adds crossref_format param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            crossref_format: 'some regex'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --crossref-format \"some regex\" \"input/dir\"")
      end

      it "adds exit_threshold param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            exit_threshold: '2'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --exit-threshold \"2\" \"input/dir\"")
      end

      it "adds docs_section_title param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            docs_section_title: 'Section title'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --docs-section-title \"Section title\" \"input/dir\"")
      end

      it "adds warnings param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            warnings: '--warn-missing-output-path --warn-missing-company-id --warn-undocumented-object'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --warn-missing-output-path --warn-missing-company-id --warn-undocumented-object \"input/dir\"")
      end

      it "adds logformat param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            logformat: '1'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --logformat \"1\" \"input/dir\"")
      end

      it "adds verbose param to command" do
        result = Fastlane::FastFile.new.parse("lane :test do
          appledoc(
            input: 'input/dir',
            verbose: '1'
          )
        end").runner.execute(:test)

        expect(result).to eq("appledoc --verbose \"1\" \"input/dir\"")
      end
    end
  end
end
