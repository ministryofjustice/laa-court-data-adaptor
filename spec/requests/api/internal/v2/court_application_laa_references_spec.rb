require "swagger_helper"
require "sidekiq/testing"

RSpec.describe "api/internal/v2/court_application_laa_references", swagger_doc: "v2/swagger.yaml", type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:subject_id) { SecureRandom.uuid }
  let(:maat_reference) { 6_839_707 }
  let(:laa_reference) do
    {
      laa_reference: {
        maat_reference:,
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

  path "/api/internal/v2/court_application_laa_references" do
    post("post laa_reference") do
      description "Post an LAA reference to CDA to link a MAAT case to a Common Platform application"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]
      parameter "$ref" => "#/components/parameters/transaction_id_header"

      response(201, "Created") do
        around do |example|
          VCR.use_cassette("laa_reference_recorder/post", tag: :maat_api) do
            example.run
          end
        end

        parameter name: :laa_reference, in: :body, required: false, type: :object,
                  schema: { "$ref": "laa_reference_post_request_body.json#" },
                  description: "The LAA issued reference to the application. CDA expects a numeric number, although HMCTS allows strings"

        let(:Authorization) { "Bearer #{token.token}" }

        before do
          allow(CourtApplicationMaatLinkCreator).to receive(:call).with(subject_id, "JaneDoe", maat_reference)

          allow(MaatApi::MaatReferenceValidator).to receive(:call).with(maat_reference: maat_reference)
            .and_return(instance_double(Faraday::Response, status: 200, body: {}, success?: true))
        end

        run_test!
      end

      context "with a blank maat_reference" do
        response(201, "created") do
          let(:Authorization) { "Bearer #{token.token}" }

          before do
            laa_reference[:laa_reference].delete(:maat_reference)

            expect(CourtApplicationMaatLinkCreator).to receive(:call)
                                                         .with(subject_id, "JaneDoe", nil)
          end

          run_test!
        end
      end

      context "with a blank user_name" do
        let(:Authorization) { "Bearer #{token.token}" }

        response("422", "Unprocessable entity") do
          before do
            laa_reference[:laa_reference].delete(:user_name)

            allow(MaatApi::MaatReferenceValidator).to receive(:call)
              .and_return(
                instance_double(Faraday::Response, status: 200, body: {}, success?: true),
              )

            expect(CourtApplicationMaatLinkCreator).not_to receive(:call)
          end

          run_test!
        end
      end

      context "with an invalid maat_reference" do
        response("422", "Unprocessable entity") do
          let(:Authorization) { "Bearer #{token.token}" }
          before { laa_reference[:laa_reference][:maat_reference] = "ABC123123" }

          before do
            expect(CourtApplicationMaatLinkCreator).not_to receive(:call)
          end

          run_test!
        end
      end

      context "when request is unauthorized" do
        response("401", "Unauthorized") do
          let(:Authorization) { nil }

          before do
            expect(CourtApplicationMaatLinkCreator).not_to receive(:call)
          end

          run_test!
        end
      end

      context "with a failing LAA Reference contract" do
        let(:subject_id) { "X" }

        before do
          allow(MaatApi::MaatReferenceValidator).to receive(:call)
            .and_return(instance_double(Faraday::Response, status: 200, body: {}, success?: true))
        end

        it "renders a JSON response with an unprocessable_content error" do
          post api_internal_v2_court_application_laa_references_path, params: laa_reference, headers: { "Authorization" => "Bearer #{token.token}" }

          expect(response.body).to include("is not a valid uuid")
          expect(response.parsed_body["error_codes"]).to eq %w[subject_id_contract_failure]
          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context "when a MAAT ID is already used by another application" do
        let(:maat_reference) { 5_635_423 }

        before do
          stub_maat_validation("already_linked_maat_reference", status: 400)
        end

        it "renders a JSON response with an unprocessable_content error and a maat_reference_already_linked error code" do
          post api_internal_v2_court_application_laa_references_path, params: laa_reference, headers: { "Authorization" => "Bearer #{token.token}" }

          expect(response.body).to include("is already linked to a case")
          expect(response.parsed_body["error_codes"]).to eq %w[maat_reference_already_linked_contract_failure]
          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context "when a MAAT ID is invalid" do
        let(:maat_reference) { 9_999_999 }

        before do
          stub_maat_validation("invalid_maat_reference", status: 400)
        end

        it "renders a JSON response with an unprocessable_content error and a maat_reference error code" do
          post api_internal_v2_court_application_laa_references_path, params: laa_reference, headers: { "Authorization" => "Bearer #{token.token}" }

          expect(response.body).to include("is invalid")
          expect(response.parsed_body["error_codes"]).to eq %w[maat_reference_contract_failure]
          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context "when Common Platform returns error" do
        response(424, "Failed Dependency on Common Platform") do
          let(:Authorization) { "Bearer #{token.token}" }

          before do
            laa_reference[:laa_reference].delete(:maat_reference)

            allow(CourtApplicationMaatLinkCreator).to receive(:call)
              .and_raise(CommonPlatform::Api::Errors::FailedDependency)
          end

          run_test!
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

        response(200, "OK") do
          around do |example|
            Sidekiq::Testing.fake!
            create(:laa_reference, defendant_id: subject_id,
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
            expect(CourtApplicationLaaReferenceUnlinker).to receive(:call).with(subject_id:,
                                                                                user_name: "JaneDoe",
                                                                                unlink_reason_code: 1,
                                                                                unlink_other_reason_text: "",
                                                                                maat_reference: maat_reference)
          end

          run_test!
        end

        context "when data is bad" do
          let(:Authorization) { "Bearer #{token.token}" }
          let(:subject_id) { "X" }

          response("422", "Unprocessable Entity") do
            before do
              expect(CourtApplicationLaaReferenceUnlinker).not_to receive(:call)
            end

            run_test!
          end
        end

        context "when subject_id is not present in local LaaReference" do
          let(:Authorization) { "Bearer #{token.token}" }
          let(:subject_id) { "fa7ca7bd-5dce-419c-88db-f42e1b7ce8a0" }

          response("404", "Defendant not found or already unlinked!") do
            run_test! do |response|
              error = JSON.parse(response.body)["error"]

              expect(error).to include("not found or already unlinked!")
            end
          end
        end

        context "when request is unauthorized" do
          response("401", "Unauthorized") do
            let(:Authorization) { nil }

            before do
              expect(CourtApplicationLaaReferenceUnlinker).not_to receive(:call)
            end

            run_test!
          end
        end

        context "when Common Platform returns error" do
          let(:subject_id) { "fa7ca7bd-5dce-419c-88db-f42e1b7ce8a0" }

          response(424, "Failed Dependency on Common Platform") do
            let(:Authorization) { "Bearer #{token.token}" }

            before do
              allow(CourtApplicationLaaReferenceUnlinker).to receive(:call)
                .and_raise(CommonPlatform::Api::Errors::FailedDependency)
            end

            run_test!
          end
        end
      end
    end
  end
end
