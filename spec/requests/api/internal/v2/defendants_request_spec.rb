# frozen_string_literal: true

require "swagger_helper"
require "sidekiq/testing"

RSpec.describe "api/internal/v2/prosecution_cases/:prosecution_case_reference/defendants/:id", type: :request, swagger_doc: "v2/swagger.yaml" do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:defendant_id) { "23d7f10a-067a-476e-bba6-bb855674e23b" }
  let(:prosecution_case_reference) { "19GD1001816" }

  let(:defendant) do
    {
      data: {
        type: "defendants",
        attributes: {
          user_name: "johnDoe",
          unlink_reason_code: 1,
          unlink_other_reason_text: "",
        },
      },
    }
  end

  around do |example|
    Sidekiq::Testing.fake! do
      example.run
    end
  end

  path "/api/internal/v2/prosecution_cases/{prosecution_case_reference}/defendants/{defendant_id}" do
    patch("patch defendant relationships") do
      description "Delete an LAA reference from Common Platform case"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]

      response(202, "Accepted") do
        parameter name: :prosecution_case_reference, in: :path, required: true, type: :string,
                  schema: {
                    "$ref": "prosecution_case.json#/prosecution_case_reference",
                  }

        parameter name: :defendant_id, in: :path, required: true, type: :uuid,
                  schema: {
                    "$ref": "defendant.json#/definitions/id",
                  },
                  description: "The unique identifier of the defendant"

        parameter name: :defendant, in: :body, required: true, type: :object,
                  schema: {
                    "$ref": "defendant.json#/definitions/resource_to_unlink",
                  },
                  description: "Object containing the user_name, unlink_reason_code and defendant_id"

        parameter "$ref" => "#/components/parameters/transaction_id_header"

        let(:Authorization) { "Bearer #{token.token}" }

        before do
          expect(UnlinkLaaReferenceWorker).to receive(:perform_async).with(String, defendant_id, "johnDoe", 1, "").and_call_original
        end

        run_test!
      end

      context "when data is bad" do
        response("400", "Bad Request") do
          let(:Authorization) { "Bearer #{token.token}" }
          let(:defendant_id) { "X" }

          parameter "$ref" => "#/components/parameters/transaction_id_header"

          before do
            expect(UnlinkLaaReferenceWorker).not_to receive(:perform_async)
          end

          run_test!
        end
      end

      context "when request is unauthorized" do
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

    get("fetch a case defendant") do
      description "find a defendant where it exists within Court Data Adaptor"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]

      parameter name: :prosecution_case_reference, in: :path, required: true, type: :string,
                schema: {
                  "$ref": "prosecution_case.json#/prosecution_case_reference",
                }

      parameter name: :defendant_id, in: :path, required: true, type: :uuid,
                schema: {
                  "$ref": "defendant.json#/definitions/id",
                },
                description: "The uuid of the defendant"

      parameter "$ref" => "#/components/parameters/transaction_id_header"

      context "with success" do
        let(:Authorization) { "Bearer #{token.token}" }
        let(:defendant_id) { "c6cf04b5-901d-4a89-a9ab-767eb57306e4" }

        around do |example|
          VCR.use_cassette("search_prosecution_case/by_prosecution_case_reference_success", record: :new_episodes) do
            example.run
          end
        end

        context "when success" do
          response(200, "Success") do
            run_test!
          end
        end

        context "when not found" do
          response("404", "Not found") do
            let(:Authorization) { "Bearer #{token.token}" }
            let(:defendant_id) { "c6cf04b5" }

            run_test!
          end
        end
      end
    end
  end
end
