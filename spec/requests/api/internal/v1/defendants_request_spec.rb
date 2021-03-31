# frozen_string_literal: true

require "swagger_helper"
require "sidekiq/testing"

RSpec.describe "Api::Internal::V1::Defendants", type: :request, swagger_doc: "v1/swagger.yaml" do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:id) { "23d7f10a-067a-476e-bba6-bb855674e23b" }
  let(:include) {}

  around do |example|
    Sidekiq::Testing.fake! do
      example.run
    end
  end

  path "/api/internal/v1/defendants/{id}" do
    get("fetch a defendant by ID") do
      description "find a defendant where it exists within Court Data Adaptor"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]

      parameter name: :id, in: :path, required: true, type: :uuid,
                schema: {
                  '$ref': "defendant.json#/definitions/id",
                },
                description: "The uuid of the defendant"

      parameter name: "include", in: :query, required: false, type: :string,
                schema: {},
                description: "Return other data through a has_many relationship </br>e.g. include=offences"

      parameter "$ref" => "#/components/parameters/transaction_id_header"

      context "with success" do
        let(:Authorization) { "Bearer #{token.token}" }
        let(:id) { "c6cf04b5-901d-4a89-a9ab-767eb57306e4" }

        before do
          # This call creates the ProsecutionCase and ProsecutionCaseDefendantOffence
          # in the CDA DB, which are currently required to query the defendant by id
          # on this api endpoint.
          # It implies that defendants are not queryable unless their case has been searched
          # for beforehand, which seems risky (albeit that VCD should always have queried the
          # case first via its searchinng options).
          #
          Api::SearchProsecutionCase.call(prosecution_case_reference: "19GD1001816")
        end

        around do |example|
          VCR.use_cassette("search_prosecution_case/by_prosecution_case_reference_success", record: :new_episodes) do
            example.run
          end
        end

        context "with no inclusions" do
          let(:include) {}

          response(200, "Success") do
            run_test!
          end
        end

        context "with offences included" do
          let(:include) { "offences" }

          response(200, "Success") do
            run_test! do |response|
              hashed = JSON.parse(response.body, symbolize_names: true)
              included_types = hashed[:included].pluck(:type)
              expect(included_types).to all(eql("offences"))
            end
          end
        end
      end

      context "when not found" do
        response("404", "Not found") do
          let(:Authorization) { "Bearer #{token.token}" }
          let(:id) { "c6cf04b5" }

          run_test!
        end
      end
    end
  end
end
