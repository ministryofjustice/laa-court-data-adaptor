# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/internal/v2/stats", swagger_doc: "v2/swagger.yaml", type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }

  path "/api/internal/v2/stats/linking" do
    get("fetch linking stats") do
      description "return an overview of linking and unlinking activity"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]

      produces "application/json"

      parameter name: :from, in: :query, required: true,
                schema: {
                  "$ref": "definitions.json#/definitions/datePattern",
                },
                description: "The first day of the current range"

      parameter name: :to, in: :query, required: true,
                schema: {
                  "$ref": "definitions.json#/definitions/datePattern",
                },
                description: "The last day of the current range"

      parameter "$ref" => "#/components/parameters/transaction_id_header"

      context "with success" do
        let(:Authorization) { "Bearer #{token.token}" }
        let(:from) { "2025-9-7" }
        let(:to) { "2025-9-13" }

        context "when success" do
          response(200, "Success") do
            run_test!
          end
        end

        context "when unauthorized" do
          response(401, "Unauthorized") do
            let(:Authorization) { nil }

            run_test!
          end
        end

        context "when invalid date" do
          response(422, "Unprocessable content") do
            let(:from) { nil }

            run_test!
          end
        end
      end
    end
  end
end
