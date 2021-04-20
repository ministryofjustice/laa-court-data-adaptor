# frozen_string_literal: true

require "swagger_helper"
require "sidekiq/testing"

RSpec.describe "api/internal/v1/laa_references", type: :request, swagger_doc: "v1/swagger.yaml" do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:defendant_id) { SecureRandom.uuid }
  let(:laa_reference) do
    {
      data: {
        type: "laa_references",
        attributes: {
          maat_reference: 1_231_231,
          user_name: "JaneDoe",
          unlink_reason_code: 1,
          unlink_other_reason_text: "",
        },
        relationships: {
          defendant: {
            data: {
              type: "defendants",
              id: defendant_id,
            },
          },
        },
      },
    }
  end

  before do
    allow(LinkValidator).to receive(:call).and_return(true)
  end

  around do |example|
    VCR.use_cassette("maat_api/maat_reference_success") do
      Sidekiq::Testing.fake! do
        example.run
      end
    end
  end

  path "/api/internal/v1/laa_references" do
    post("post laa_reference") do
      description "Post an LAA reference to CDA to link a MAAT case to a Common Platform case"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]

      response(202, "Accepted") do
        around do |example|
          Sidekiq::Testing.fake!
          VCR.use_cassette("laa_reference_recorder/update") do
            example.run
          end
        end

        parameter name: :laa_reference, in: :body, required: false, type: :object,
                  schema: {
                    '$ref': "laa_reference.json#/definitions/new_resource",
                  },
                  description: "The LAA issued reference to the application. CDA expects a numeric number, although HMCTS allows strings"

        parameter "$ref" => "#/components/parameters/transaction_id_header"

        let(:Authorization) { "Bearer #{token.token}" }

        before do
          expect(LaaReferenceCreator).to receive(:call).with(defendant_id: defendant_id, user_name: "JaneDoe", maat_reference: 1_231_231).and_call_original
        end

        run_test!
      end

      context "with a blank maat_reference" do
        response(202, "Accepted") do
          let(:Authorization) { "Bearer #{token.token}" }

          parameter "$ref" => "#/components/parameters/transaction_id_header"

          before do
            laa_reference[:data][:attributes].delete(:maat_reference)
            expect(LaaReferenceCreator).to receive(:call).with(defendant_id: defendant_id, user_name: "JaneDoe", maat_reference: nil).and_call_original
          end

          run_test!
        end
      end

      context "with a blank user_name" do
        response("422", "Unprocessable entity") do
          let(:Authorization) { "Bearer #{token.token}" }

          parameter "$ref" => "#/components/parameters/transaction_id_header"

          before do
            laa_reference[:data][:attributes].delete(:user_name)
            expect(LaaReferenceCreator).not_to receive(:call)
          end

          run_test!
        end
      end

      context "with an invalid maat_reference" do
        response("422", "Unprocessable entity") do
          let(:Authorization) { "Bearer #{token.token}" }
          before { laa_reference[:data][:attributes][:maat_reference] = "ABC123123" }

          parameter "$ref" => "#/components/parameters/transaction_id_header"

          before do
            expect(LaaReferenceCreator).not_to receive(:call)
          end

          run_test!
        end
      end

      context "when request is unauthorized" do
        response("401", "Unauthorized") do
          let(:Authorization) { nil }

          parameter "$ref" => "#/components/parameters/transaction_id_header"

          before do
            expect(LaaReferenceCreator).not_to receive(:call)
          end

          run_test!
        end
      end

      context "when we are attempting to create an LaaReference that already exists" do
        it "includes error message in JSON response" do
          LaaReference.create!(defendant_id: defendant_id, maat_reference: 1_231_231, user_name: "JaneDoe")

          post api_internal_v1_laa_references_path, params: laa_reference, headers: { "Authorization" => "Bearer #{token.token}" }

          expect(response).to have_http_status :bad_request
          expect(JSON.parse(response.body)).to eql({ "error" => "Validation failed: Maat reference has already been taken" })
        end
      end

      context "with a failing LAA Reference contract" do
        before { laa_reference[:data][:relationships][:defendant][:data][:id] = "foo" }

        it "renders a JSON response with an unprocessable_entity error" do
          post api_internal_v1_laa_references_path, params: laa_reference, headers: { "Authorization" => "Bearer #{token.token}" }

          expect(response.body).to include("is not a valid uuid")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  path "/api/internal/v1/laa_references/{defendant_id}" do
    delete("delete laa_reference") do
      description "Delete an LAA reference from Common Platform case"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]

      response(202, "Accepted") do
        parameter name: :defendant_id, in: :path, required: true, type: :uuid,
                  schema: {
                    '$ref': "defendant.json#/definitions/id",
                  },
                  description: "The unique identifier of the defendant"

        parameter name: :laa_reference, in: :body, required: true, type: :object,
                  schema: {
                    '$ref': "laa_reference.json#/definitions/unlink",
                  },
                  description: "Object containing the user_name, unlink_reason_code and unlink_other_reason_text"

        parameter "$ref" => "#/components/parameters/transaction_id_header"

        let(:Authorization) { "Bearer #{token.token}" }

        before do
          expect(UnlinkLaaReferenceWorker).to receive(:perform_async).with(String, defendant_id, "JaneDoe", 1, "")
        end

        run_test!
      end

      response("422", "Unprocessable Entity") do
        let(:Authorization) { "Bearer #{token.token}" }
        let(:defendant_id) { "X" }

        parameter "$ref" => "#/components/parameters/transaction_id_header"

        before do
          expect(UnlinkLaaReferenceWorker).not_to receive(:perform_async)
        end

        run_test!
      end

      response("401", "Unauthorized") do
        let(:Authorization) { nil }

        parameter "$ref" => "#/components/parameters/transaction_id_header"

        before do
          expect(UnlinkLaaReferenceWorker).not_to receive(:perform_async)
        end

        run_test!
      end
    end
  end
end
