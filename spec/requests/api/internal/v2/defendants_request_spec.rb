# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/internal/v2/defendants", swagger_doc: "v2/swagger.yaml", type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:prosecution_case_reference) { "30DI0570888" }
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
        let(:id) { "b760daba-0d38-4bae-ad57-fbfd8419aefe" }

        before do
          stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/prosecutionCases?prosecutionCaseReference=#{prosecution_case_reference}")
              .to_return(
                status: 200,
                headers: { content_type: "application/json" },
                body: file_fixture("search_prosecution_case_response.json").read,
              )
        end

        context "when success" do
          response(200, "Success") do
            schema "$ref" => "defendant_summary.json#"
            run_test!
          end
        end

        context "when not found" do
          response(404, "Not found") do
            let(:Authorization) { "Bearer #{token.token}" }
            let(:id) { "c6cf04b5" }

            run_test!
          end
        end

        context "when unauthorized" do
          response(401, "Unauthorized") do
            let(:Authorization) { nil }

            run_test!
          end
        end
      end
    end
  end

  path "/api/internal/v2/prosecution_cases/{prosecution_case_reference}/defendants/{id}/offence_history" do
    get("fetch a case defendant's offence history") do
      description "retrieves the plea history and mode of trial reason history for every offence a defendant has"
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
        let(:id) { "b760daba-0d38-4bae-ad57-fbfd8419aefe" }
        let(:hearing_ids) { %w[9b8df2aa-802d-413a-82b3-89eff25cde7b 2816b8d4-f141-4c39-82fc-a98c6fb3fcfa] }

        before do
          hearing_ids.each do |hearing_id|
            stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/hearing/results?hearingId=#{hearing_id}")
              .to_return(
                headers: { content_type: "application/json" },
                body: file_fixture("hearing_resulted.json").read,
              )
          end
          stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/prosecutionCases?prosecutionCaseReference=#{prosecution_case_reference}")
              .to_return(
                status: 200,
                headers: { content_type: "application/json" },
                body: file_fixture("search_prosecution_case_response.json").read,
              )
        end

        context "when success" do
          response(200, "Success") do
            schema "$ref" => "defendant_offence_history.json#"
            run_test!
          end
        end

        context "when not found" do
          response(404, "Not found") do
            let(:Authorization) { "Bearer #{token.token}" }
            let(:id) { "c6cf04b5" }

            run_test!
          end
        end

        context "when unauthorized" do
          response(401, "Unauthorized") do
            let(:Authorization) { nil }

            run_test!
          end
        end
      end
    end
  end
end
