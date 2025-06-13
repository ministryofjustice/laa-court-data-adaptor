require "swagger_helper"
require "sidekiq/testing"

RSpec.describe "api/internal/v2/court_application_laa_references", swagger_doc: "v2/swagger.yaml", type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:subject_id) { SecureRandom.uuid }
  let(:laa_reference) do
    {
      laa_reference: {
        maat_reference: 1_231_231,
        user_name: "JaneDoe",
        unlink_reason_code: 1,
        unlink_other_reason_text: "",
        subject_id:,
      },
    }
  end

  before do
    allow(Current).to receive(:request_id).and_return("XYZ")
    allow(CourtApplicationLinkValidator).to receive(:call).and_return(true)
  end

  around do |example|
    VCR.use_cassette("maat_api/maat_reference_success") do
      Sidekiq::Testing.fake! do
        example.run
      end
    end
  end

  path "/api/internal/v2/court_application_laa_references" do
    post("post laa_reference") do
      description "Post an LAA reference to CDA to link a MAAT case to a Common Platform application"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]
      parameter "$ref" => "#/components/parameters/transaction_id_header"

      response(202, "Accepted") do
        around do |example|
          Sidekiq::Testing.fake!
          VCR.use_cassette("laa_reference_recorder/post") do
            example.run
          end
        end

        parameter name: :laa_reference, in: :body, required: false, type: :object,
                  schema: { "$ref": "laa_reference_post_request_body.json#" },
                  description: "The LAA issued reference to the application. CDA expects a numeric number, although HMCTS allows strings"

        let(:Authorization) { "Bearer #{token.token}" }

        # before do
        #   expect(CourtApplicationMaatLinkCreatorWorker).to receive(:perform_async)
        #     .with("XYZ", subject_id, "JaneDoe", 1_231_231)
        # end

        run_test!
      end

      context "with a blank maat_reference" do
        response(202, "Accepted") do
          let(:Authorization) { "Bearer #{token.token}" }

          before do
            laa_reference[:laa_reference].delete(:maat_reference)

            # expect(CourtApplicationMaatLinkCreatorWorker).to receive(:perform_async)
            #   .with("XYZ", subject_id, "JaneDoe", nil)
          end

          run_test!
        end
      end

      context "with a blank user_name" do
        response("422", "Unprocessable entity") do
          let(:Authorization) { "Bearer #{token.token}" }

          before do
            laa_reference[:laa_reference].delete(:user_name)
            # expect(CourtApplicationMaatLinkCreatorWorker).not_to receive(:perform_async)
          end

          run_test!
        end
      end

      context "with an invalid maat_reference" do
        response("422", "Unprocessable entity") do
          let(:Authorization) { "Bearer #{token.token}" }
          before { laa_reference[:laa_reference][:maat_reference] = "ABC123123" }

          # before do
          #   expect(CourtApplicationMaatLinkCreatorWorker).not_to receive(:perform_async)
          # end

          run_test!
        end
      end

      context "when request is unauthorized" do
        response("401", "Unauthorized") do
          let(:Authorization) { nil }

          # before do
          #   expect(CourtApplicationMaatLinkCreatorWorker).not_to receive(:perform_async)
          # end

          run_test!
        end
      end

      context "with a failing LAA Reference contract" do
        let(:subject_id) { "X" }

        it "renders a JSON response with an unprocessable_entity error" do
          post api_internal_v2_court_application_laa_references_path, params: laa_reference, headers: { "Authorization" => "Bearer #{token.token}" }

          expect(response.body).to include("is not a valid uuid")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    path "/api/internal/v2/court_application_laa_references/{subject_id}" do
      patch("update laa_reference") do
        description "Update an LAA reference (mark as unlinked)"
        consumes "application/json"
        tags "Internal - available to other LAA applications"
        security [{ oAuth: [] }]
        parameter "$ref" => "#/components/parameters/transaction_id_header"

        response(202, "Accepted") do
          around do |example|
            Sidekiq::Testing.fake!
            LaaReference.create!(defendant_id: subject_id,
                                 linked: true,
                                 maat_reference: laa_reference[:laa_reference][:maat_reference],
                                 user_name: "Jack")
            VCR.use_cassette("laa_reference_recorder/update") do
              example.run
            end
          end

          parameter name: :subject_id, in: :path, required: false, type: :uuid,
                    schema: {
                      "$ref": "defendant.json#/properties/id",
                    },
                    description: "The unique identifier of the defendant"

          parameter name: :laa_reference, in: :body, required: true, type: :object,
                    schema: {
                      "$ref": "laa_reference_patch_request_body.json#",
                    },
                    description: "The LAA issued reference to the application. CDA expects a numeric number, although HMCTS allows strings"

          let(:Authorization) { "Bearer #{token.token}" }

          before do
            expect(UnlinkCourtApplicationLaaReferenceWorker).to receive(:perform_async).with("XYZ", subject_id, "JaneDoe", 1, "", 1_231_231)
          end

          run_test!
        end

        context "when data is bad" do
          response("422", "Unprocessable Entity") do
            let(:Authorization) { "Bearer #{token.token}" }
            let(:subject_id) { "X" }

            before do
              expect(UnlinkProsecutionCaseLaaReferenceWorker).not_to receive(:perform_async)
            end

            run_test!
          end
        end

        context "when subject_id is nonexistent" do
          response("404", "Defendant not found") do
            let(:Authorization) { "Bearer #{token.token}" }

            let(:subject_id) { "fa7ca7bd-5dce-419c-88db-f42e1b7ce8a0" }

            run_test! do |response|
              error = JSON.parse(response.body)["error"]

              expect(error).to include("Couldn't find LaaReference")
            end
          end
        end

        context "when request is unauthorized" do
          response("401", "Unauthorized") do
            let(:Authorization) { nil }

            before do
              expect(UnlinkProsecutionCaseLaaReferenceWorker).not_to receive(:perform_async)
            end

            run_test!
          end
        end
      end
    end
  end
end
