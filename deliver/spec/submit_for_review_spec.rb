require 'deliver/submit_for_review'
require 'ostruct'

describe Deliver::SubmitForReview do
  let(:review_submitter) { Deliver::SubmitForReview.new }

  describe 'submit app' do
    let(:app) { double('app') }
    let(:edit_version) do
      double('edit_version',
             id: '1',
             version_string: "1.0.0")
    end
    let(:ready_for_review_version) do
      double('ready_for_review_version',
             id: '1',
             app_version_state: "READY_FOR_REVIEW",
             version_string: "1.0.0")
    end
    let(:prepare_for_submission_version) do
      double('prepare_for_submission_version',
             id: '1',
             app_version_state: "PREPARE_FOR_SUBMISSION",
             version_string: "1.0.0")
    end
    let(:selected_build) { double('selected_build') }

    let(:submission) do
      double('submission',
             id: '1')
    end

    before do
      allow(Deliver).to receive(:cache).and_return({ app: app })
    end

    context 'submit fails' do
      it 'no version' do
        options = {
          platform: Spaceship::ConnectAPI::Platform::IOS
        }

        expect(app).to receive(:get_edit_app_store_version).and_return(nil)

        expect(UI).to receive(:user_error!).with(/Cannot submit for review - could not find an editable version for/).and_raise("boom")

        expect do
          review_submitter.submit!(options)
        end.to raise_error("boom")
      end

      it 'needs to set export_compliance_uses_encryption' do
        options = {
          platform: Spaceship::ConnectAPI::Platform::IOS
        }

        expect(app).to receive(:get_edit_app_store_version).and_return(edit_version)
        expect(review_submitter).to receive(:select_build).and_return(selected_build)

        expect(selected_build).to receive(:uses_non_exempt_encryption).and_return(nil)

        expect(UI).to receive(:user_error!).with(/Export compliance is required to submit/).and_raise("boom")

        expect do
          review_submitter.submit!(options)
        end.to raise_error("boom")
      end
    end

    context 'submits successfully' do
      describe 'no options' do

        it 'with in progress review submission' do
          options = {
            platform: Spaceship::ConnectAPI::Platform::IOS
          }

          expect(app).to receive(:get_edit_app_store_version).and_return(edit_version)
          expect(review_submitter).to receive(:select_build).and_return(selected_build)

          expect(selected_build).to receive(:uses_non_exempt_encryption).and_return(false)

          expect(app).to receive(:get_in_progress_review_submission).and_return(submission)

          expect do
            review_submitter.submit!(options)
          end.to raise_error("Cannot submit for review - A review submission is already in progress")
        end

        it 'with empty submission' do
          options = {
            platform: Spaceship::ConnectAPI::Platform::IOS
          }

          expect(app).to receive(:get_edit_app_store_version).and_return(edit_version)
          expect(review_submitter).to receive(:select_build).and_return(selected_build)

          expect(selected_build).to receive(:uses_non_exempt_encryption).and_return(false)

          expect(app).to receive(:get_in_progress_review_submission).and_return(nil)
          expect(app).to receive(:get_ready_review_submission).and_return(submission)
          expect(submission).to receive(:items).and_return([])
          expect(app).not_to receive(:create_review_submission)

          expect(submission).to receive(:add_app_store_version_to_review_items).with(app_store_version_id: edit_version.id)
          expect(Spaceship::ConnectAPI::AppStoreVersion).to receive(:get).and_return(ready_for_review_version)
          expect(submission).to receive(:submit_for_review)

          review_submitter.submit!(options)
        end

        it 'with submission containing items' do
          options = {
            platform: Spaceship::ConnectAPI::Platform::IOS
          }

          expect(app).to receive(:get_edit_app_store_version).and_return(edit_version)
          expect(review_submitter).to receive(:select_build).and_return(selected_build)

          expect(selected_build).to receive(:uses_non_exempt_encryption).and_return(false)

          expect(app).to receive(:get_in_progress_review_submission).and_return(nil)
          expect(app).to receive(:get_ready_review_submission).and_return(submission)
          expect(submission).to receive(:items).and_return([double('some item')])

          expect do
            review_submitter.submit!(options)
          end.to raise_error("Cannot submit for review - A review submission already exists with items not managed by fastlane. Please cancel or remove items from submission for the App Store Connect website")
        end
      end

      context 'it still tries to submit for review if the version state is not expected' do
        it 'retires to get the version state at most 10 times' do
          options = {
            platform: Spaceship::ConnectAPI::Platform::IOS
          }

          expect(app).to receive(:get_edit_app_store_version).and_return(edit_version)
          expect(review_submitter).to receive(:select_build).and_return(selected_build)

          expect(selected_build).to receive(:uses_non_exempt_encryption).and_return(false)

          expect(app).to receive(:get_in_progress_review_submission).and_return(nil)
          expect(app).to receive(:get_ready_review_submission).and_return(submission)
          expect(submission).to receive(:items).and_return([])
          expect(app).not_to receive(:create_review_submission)

          expect(submission).to receive(:add_app_store_version_to_review_items).with(app_store_version_id: edit_version.id)
          allow_any_instance_of(Deliver::SubmitForReview).to receive(:sleep)
          expect(Spaceship::ConnectAPI::AppStoreVersion).to receive(:get).exactly(10).times.and_return(prepare_for_submission_version)
          expect(submission).to receive(:submit_for_review)

          review_submitter.submit!(options)
        end
      end

      context 'export_compliance_uses_encryption' do
        it 'sets to false' do
          options = {
            platform: Spaceship::ConnectAPI::Platform::IOS,
            submission_information: {
              export_compliance_uses_encryption: false
            }
          }

          expect(app).to receive(:get_edit_app_store_version).and_return(edit_version)
          expect(review_submitter).to receive(:select_build).and_return(selected_build)

          expect(selected_build).to receive(:uses_non_exempt_encryption).and_return(nil)
          expect(selected_build).to receive(:update).with(attributes: { usesNonExemptEncryption: false }).and_return(selected_build)
          expect(selected_build).to receive(:uses_non_exempt_encryption).and_return(false)

          expect(app).to receive(:get_in_progress_review_submission).and_return(nil)
          expect(app).to receive(:get_ready_review_submission).and_return(nil)
          expect(app).to receive(:create_review_submission).and_return(submission)

          expect(submission).to receive(:add_app_store_version_to_review_items).with(app_store_version_id: edit_version.id)
          expect(Spaceship::ConnectAPI::AppStoreVersion).to receive(:get).and_return(ready_for_review_version)
          expect(submission).to receive(:submit_for_review)

          review_submitter.submit!(options)
        end
      end

      context 'content_rights_contains_third_party_content' do
        it 'sets to true' do
          options = {
            platform: Spaceship::ConnectAPI::Platform::IOS,
            submission_information: {
              content_rights_contains_third_party_content: true
            }
          }

          expect(app).to receive(:get_edit_app_store_version).and_return(edit_version)
          expect(review_submitter).to receive(:select_build).and_return(selected_build)

          expect(selected_build).to receive(:uses_non_exempt_encryption).and_return(false)

          expect(app).to receive(:update).with(attributes: {
            contentRightsDeclaration: "USES_THIRD_PARTY_CONTENT"
          })

          expect(app).to receive(:get_in_progress_review_submission).and_return(nil)
          expect(app).to receive(:get_ready_review_submission).and_return(nil)
          expect(app).to receive(:create_review_submission).and_return(submission)

          expect(submission).to receive(:add_app_store_version_to_review_items).with(app_store_version_id: edit_version.id)
          expect(Spaceship::ConnectAPI::AppStoreVersion).to receive(:get).and_return(ready_for_review_version)
          expect(submission).to receive(:submit_for_review)

          review_submitter.submit!(options)
        end
      end
    end
  end
end
