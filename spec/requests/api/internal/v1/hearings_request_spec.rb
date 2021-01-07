# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::Internal::V1::Hearings", type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:include) {}
  let(:id) { "4d01840d-5959-4539-a450-d39f57171036" }

  path "/api/internal/v1/hearings/{id}" do
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

      parameter name: "include", in: :query, required: false, type: :string,
                schema: {},
                description: "Return other data through a has_many relationship </br>e.g. include=hearing_events"

      parameter "$ref" => "#/components/parameters/transaction_id_header"

      context "with success" do
        let(:Authorization) { "Bearer #{token.token}" }
        let(:shared_time) { JSON.parse(file_fixture("valid_hearing.json").read) }

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

        context "with hearing_events included" do
          let(:include) { "hearing_events" }

          response(200, "Success") do
            run_test! do |response|
              hashed = JSON.parse(response.body, symbolize_names: true)
              included_types = hashed[:included].pluck(:type)
              expect(included_types).to all(eql("hearing_events"))
            end
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
