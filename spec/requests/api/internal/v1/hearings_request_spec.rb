# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/internal/v1/hearings", type: :request, swagger_doc: "v1/swagger.yaml" do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:include) {}
  let(:id) { "4d01840d-5959-4539-a450-d39f57171036" }
  let(:sitting_day) {}

  path "/api/internal/v1/hearings/{id}" do
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

        context "with the inclusion of hearing events, providers, court applications, prosecution cases, cracked ineffective trial and defendant judicial results" do
          response(200, "Success") do
            parameter name: :include, in: :query, required: false, type: :string,
                      schema: {
                        "$ref": "hearing.json#/definitions/example_included_query_parameters",
                      },
                      description: "Include top-level and nested associations for a hearing.
                                    All top-level and nested associations available for inclusion are listed under the relationships keys of the response body.
                                    For example to include hearing events, providers, prosecution cases, cracked ineffective trial as well as court applications and associated judicial results:
                                    include=hearing_events,providers,court_applications,prosecution_cases,cracked_ineffective_trial,court_applications.judicial_results"

            schema "$ref" => "hearing.json#/definitions/resource_collection"

            run_test!
          end
        end
      end

      context "when request is unauthorized" do
        let(:Authorization) { nil }

        response(401, "Unauthorized") do
          run_test!
        end
      end

      context "when Hearing Result does not exist on Common Platform" do
        let(:Authorization) { "Bearer #{token.token}" }
        let(:id) { "123" }

        before do
          stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/hearing/results?hearingId=#{id}")
            .to_return(
              status: 200,
              headers: { content_type: "application/json" },
              body: "{}",
            )
        end

        describe "response" do
          response(404, "Not found") do
            run_test!
          end
        end
      end

      context "with sitting day query parameter" do
        let(:Authorization) { "Bearer #{token.token}" }
        let(:sitting_day) { "2020-08-17" }

        parameter name: :sitting_day, in: :query, required: false, type: :string, format: :datetime,
                  schema: {
                    "$ref": "hearing.json#/definitions/hearingDay/properties/sittingDay",
                  },
                  description: "The sitting day of the hearing"

        around do |example|
          VCR.use_cassette("hearing_result_fetcher/success_specified_sitting_day") do
            VCR.use_cassette("hearing_logs_fetcher/success") do
              example.run
            end
          end
        end

        context "with success" do
          response(200, "Success") do
            run_test!
          end
        end
      end
    end
  end
end
