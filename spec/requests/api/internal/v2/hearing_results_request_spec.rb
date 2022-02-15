# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/internal/v2/hearing_results", type: :request, swagger_doc: "v2/swagger.yaml" do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:id) { "4d01840d-5959-4539-a450-d39f57171036" }

  path "/api/internal/v2/hearing_results/{id}" do
    get("get hearing") do
      description "GET Common Platform hearing data"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]

      produces "application/vnd.api+json"

      parameter name: :id, in: :path, required: true, type: :uuid,
                schema: {
                  '$ref': "hearing.json#/definitions/id",
                },
                description: "The uuid of the hearing"

      parameter "$ref" => "#/components/parameters/transaction_id_header"

      let(:Authorization) { "Bearer #{token.token}" }
      let(:shared_time) { JSON.parse(file_fixture("hearing/valid.json").read) }

      around do |example|
        VCR.use_cassette("hearing_result_fetcher/success") do
          example.run
        end
      end

      context "when success" do
        response(200, "Success") do
          schema "$ref" => "hearing.json#/definitions/resource_collection"
          run_test!
        end
      end

      context "when unauthorized" do
        response(401, "Unauthorized") do
          let(:Authorization) { nil }
          parameter "$ref" => "#/components/parameters/transaction_id_header"
          run_test!
        end
      end
    end
  end
end
