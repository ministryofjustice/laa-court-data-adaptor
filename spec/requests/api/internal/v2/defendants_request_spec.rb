# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/internal/v2/defendants", type: :request, swagger_doc: "v2/swagger.yaml" do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:id) { "23d7f10a-067a-476e-bba6-bb855674e23b" }
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

  path "/api/internal/v2/prosecution_cases/{prosecution_case_reference}/defendants/{id}" do
    get("fetch a case defendant by ID") do
      description "find a defendant where it exists within Court Data Adaptor"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]

      produces "application/vnd.api+json"

      parameter name: :prosecution_case_reference, in: :path, required: true,
                schema: {
                  "$ref": "prosecution_case_identifier.json#/properties/case_urn",
                },
                description: "The unique reference number (URN) of the case"

      parameter name: :id, in: :path, required: true, type: :uuid,
                schema: {
                  "$ref": "defendant.json#/properties/id",
                },
                description: "The uuid of the defendant"

      parameter "$ref" => "#/components/parameters/transaction_id_header"

      context "with success" do
        let(:Authorization) { "Bearer #{token.token}" }
        let(:id) { "c6cf04b5-901d-4a89-a9ab-767eb57306e4" }

        around do |example|
          VCR.use_cassette("search_prosecution_case/by_prosecution_case_reference_success") do
            example.run
          end
        end

        context "when success" do
          response(200, "Success") do
            # schema "$ref" => "defendant_summary.json#"
            run_test!
          end
        end

        context "when not found" do
          response("404", "Not found") do
            let(:Authorization) { "Bearer #{token.token}" }
            let(:id) { "c6cf04b5" }

            run_test!
          end
        end

        context "when unauthorized" do
          response("401", "Unauthorized") do
            let(:Authorization) { nil }

            run_test!
          end
        end
      end
    end
  end
end
