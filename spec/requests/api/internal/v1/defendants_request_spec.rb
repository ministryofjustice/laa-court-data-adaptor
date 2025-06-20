# frozen_string_literal: true

require "swagger_helper"
require "sidekiq/testing"

RSpec.describe "Api::Internal::V1::Defendants", swagger_doc: "v1/swagger.yaml", type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:id) { "23d7f10a-067a-476e-bba6-bb855674e23b" }
  let(:include) {}
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

  before do
    allow(CommonPlatform::Api::GetHearingResults).to receive(:call)
  end

  around do |example|
    Sidekiq::Testing.fake! do
      example.run
    end
  end

  path "/api/internal/v1/defendants/{id}" do
    patch("patch defendant relationships") do
      description "Delete an LAA reference from Common Platform case"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]
      parameter "$ref" => "#/components/parameters/transaction_id_header"

      response(202, "Accepted") do
        parameter name: :id, in: :path, required: true, type: :uuid,
                  schema: {
                    "$ref": "defendant.json#/definitions/id",
                  },
                  description: "The unique identifier of the defendant"

        parameter name: :defendant, in: :body, required: true, type: :object,
                  schema: {
                    "$ref": "defendant.json#/definitions/resource_to_unlink",
                  },
                  description: "Object containing the user_name, unlink_reason_code and defendant_id"

        let(:Authorization) { "Bearer #{token.token}" }

        before do
          expect(UnlinkProsecutionCaseLaaReferenceWorker).to receive(:perform_async).with(String, id, "johnDoe", 1, "").and_call_original
        end

        run_test!
      end

      context "when data is bad" do
        response("400", "Bad Request") do
          let(:Authorization) { "Bearer #{token.token}" }
          let(:id) { "X" }

          before do
            expect(UnlinkProsecutionCaseLaaReferenceWorker).not_to receive(:perform_async)
          end

          run_test!
        end
      end

      context "when request is unauthorized" do
        response("401", "Unauthorized") do
          let(:Authorization) { nil }

          before do
            expect(UnlinkProsecutionCaseLaaReferenceWorker).not_to receive(:perform_async)
          end

          run_test!
        end
      end
    end

    get("fetch a defendant by ID") do
      description "find a defendant where it exists within Court Data Adaptor"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]

      parameter name: :id, in: :path, required: true, type: :uuid,
                schema: {
                  "$ref": "defendant.json#/definitions/id",
                },
                description: "The uuid of the defendant"

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
          CommonPlatform::Api::SearchProsecutionCase.call(prosecution_case_reference: "19GD1001816")
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

        context "with the inclusion of offences, defence organisation, prosecution case and its associated hearing summaries" do
          response(200, "Success") do
            produces "application/vnd.api+json"

            parameter name: "include", in: :query, required: false, type: :string,
                      schema: {
                        "$ref": "defendant.json#/definitions/example_included_query_parameters",
                      },
                      description: "Include top-level and nested associations for a defendant.
                                    All top-level and nested associations available for inclusion are listed under the relationships keys of the response body.
                                    For example to include offences, defence organisation as well as prosecution case and its associated hearing summaries:
                                    include=offences,defence_organisation,prosecution_case,prosecution_case.hearing_summaries"

            schema "$ref" => "defendant.json#/definitions/resource_collection"

            run_test!
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
