describe Fastlane do
  describe Fastlane::FastFile do
    describe 'Update Project Provisioning' do
      let(:fixtures_path) { './fastlane/spec/fixtures' }
      let(:xcodeproj) do
        File.absolute_path(
          File.join(fixtures_path, 'xcodeproj', 'bundle.xcodeproj')
        )
      end
      let(:profile_path) do
        File.absolute_path(
          File.join(fixtures_path, 'profiles', 'test.mobileprovision')
        )
      end
      describe 'target_filter' do
        before do
          allow(Fastlane::Actions::UpdateProjectProvisioningAction).to receive(
                     :run
                   )
        end

        context 'with String' do
          it 'should be valid' do
            expect do
              Fastlane::FastFile.new.parse(
                "lane :test do
                  update_project_provisioning ({
                    xcodeproj: '#{xcodeproj}',
                    profile: '#{profile_path}',
                    target_filter: 'Name'
                })
              end"
              )
                .runner
                .execute(:test)
            end.not_to(raise_error)
          end
        end

        context 'with Regexp' do
          it 'should be valid' do
            expect do
              Fastlane::FastFile.new.parse(
                "lane :test do
                  update_project_provisioning ({
                    xcodeproj: '#{xcodeproj}',
                    profile: '#{profile_path}',
                    target_filter: /Name/
                })
              end"
              )
                .runner
                .execute(:test)
            end.not_to(raise_error)
          end
        end

        context 'with other type' do
          it 'should be invalid' do
            expect do
              Fastlane::FastFile.new.parse(
                "lane :test do
                  update_project_provisioning ({
                    xcodeproj: '#{xcodeproj}',
                    profile: '#{profile_path}',
                    target_filter: 1
                })
              end"
              )
                .runner
                .execute(:test)
            end.to raise_error(FastlaneCore::Interface::FastlaneError)
          end
        end
      end

      describe 'build_configuration' do
        before do
          allow(Fastlane::Actions::UpdateProjectProvisioningAction).to receive(
                     :run
                   )
        end

        context 'with String' do
          it 'should be valid' do
            expect do
              Fastlane::FastFile.new.parse(
                "lane :test do
                  update_project_provisioning ({
                    xcodeproj: '#{xcodeproj}',
                    profile: '#{profile_path}',
                    build_configuration: 'Debug'
                })
              end"
              )
                .runner
                .execute(:test)
            end.not_to(raise_error)
          end
        end

        context 'with Regexp' do
          it 'should be valid' do
            expect do
              Fastlane::FastFile.new.parse(
                "lane :test do
                  update_project_provisioning ({
                    xcodeproj: '#{xcodeproj}',
                    profile: '#{profile_path}',
                    build_configuration: /Debug/
                })
              end"
              )
                .runner
                .execute(:test)
            end.not_to(raise_error)
          end
        end

        context 'with other type' do
          it 'should be invalid' do
            expect do
              Fastlane::FastFile.new.parse(
                "lane :test do
                  update_project_provisioning ({
                    xcodeproj: '#{xcodeproj}',
                    profile: '#{profile_path}',
                    build_configuration: 1
                })
              end"
              )
                .runner
                .execute(:test)
            end.to raise_error(FastlaneCore::Interface::FastlaneError)
          end
        end
      end
    end
  end
end
