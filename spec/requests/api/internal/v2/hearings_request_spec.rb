# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/internal/v2/hearings", type: :request, swagger_doc: "v2/swagger.yaml" do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:include) {}
  let(:id) { "4d01840d-5959-4539-a450-d39f57171036" }

  path "/api/internal/v2/hearings/{id}" do
    get("get hearing") do
      description "GET Common Platform hearing data"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]

      parameter name: :id, in: :path, required: true, type: :uuid,
                schema: {
                  '$ref': "hearing.json#/definitions/id",
                },
                description: "The uuid of the hearing"

      parameter "$ref" => "#/components/parameters/transaction_id_header"

      context "with success" do
        let(:Authorization) { "Bearer #{token.token}" }
        let(:shared_time) { JSON.parse(file_fixture("hearing/valid.json").read) }

        around do |example|
          VCR.use_cassette("hearing_result_fetcher/success") do
            VCR.use_cassette("hearing_logs_fetcher/success") do
              example.run
            end
          end
        end

        context "with no inclusions" do
          let(:include) {}

          response(200, "Success") do
            run_test!
          end
        end

        context "with the inclusion of hearing events, providers, court applications, cracked ineffective trial and judicial results" do
          response(200, "Success") do
            produces "application/vnd.api+json"

            parameter name: "include", in: :query, required: false, type: :string,
                      schema: {
                        "$ref": "hearing.json#/definitions/example_included_query_parameters",
                      },
                      description: "Include top-level and nested associations for a hearing. All top-level and nested
                                   associations available for inclusion are listed under the relationships keys of the response body.
                                   For example to include providers, cracked ineffective trial as well as court applications and associated judicial results:
                                   include=providers,court_applications,cracked_ineffective_trial,court_applications.judicial_results"

            schema "$ref" => "hearing.json#/definitions/resource_collection"

            run_test!
          end
        end
      end

      context "when request is unauthorized" do
        response("401", "Unauthorized") do
          around do |example|
            VCR.use_cassette("hearing_result_fetcher/unauthorised") do
              example.run
            end
          end

          let(:Authorization) { nil }

          parameter "$ref" => "#/components/parameters/transaction_id_header"

          run_test!
        end
      end
    end
  end
end
