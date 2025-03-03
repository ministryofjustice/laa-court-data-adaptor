# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/internal/v2/hearing_results", swagger_doc: "v2/swagger.yaml", type: :request do
  include AuthorisedRequestHelper

  path "/api/internal/v2/hearing_results/{hearing_id}" do
    get("get hearing") do
      description "GET Common Platform hearing data"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]

      produces "application/vnd.api+json"

      parameter name: :hearing_id, in: :path, required: true, type: :uuid,
                schema: {
                  '$ref': "definitions.json#/definitions/uuid",
                },
                description: "The uuid of the hearing"

      parameter "$ref" => "#/components/parameters/transaction_id_header"

      let(:Authorization) { "Bearer #{access_token.token}" }
      let(:sitting_day) { nil }

      context "when Hearing Result exists on Common Platform" do
        let(:hearing_id) { "b935a64a-6d03-4da4-bba6-4d32cc2e7fb4" }

        before do
          stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/hearing/results?hearingId=#{hearing_id}")
            .to_return(
              headers: { content_type: "application/json" },
              body: file_fixture("hearing_resulted.json").read,
            )
        end

        describe "response" do
          response(200, "Success") do
            schema "$ref" => "hearing_result.json#"
            parameter "$ref" => "#/components/parameters/transaction_id_header"
            run_test!
          end
        end
      end

      context "when unauthorized" do
        response(401, "Unauthorized") do
          let(:hearing_id) { "b935a64a-6d03-4da4-bba6-4d32cc2e7fb4" }
          let(:Authorization) { nil }

          parameter "$ref" => "#/components/parameters/transaction_id_header"
          run_test!
        end
      end

      context "when Hearing Result does not exist on Common Platform" do
        let(:hearing_id) { "123" }

        before do
          stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/hearing/results?hearingId=#{hearing_id}")
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
        let(:hearing_id) { "b935a64a-6d03-4da4-bba6-4d32cc2e7fb4" }
        let(:sitting_day) { "2020-08-17" }

        parameter name: :sitting_day, in: :query, required: false, type: :string, format: :datetime,
                  schema: {
                    "$ref": "definitions.json#/definitions/datePattern",
                  },
                  description: "The sitting day of the hearing"

        before do
          stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/hearing/results?hearingId=#{hearing_id}&sittingDay=#{sitting_day}")
            .to_return(
              status: 200,
              headers: { content_type: "application/json" },
              body: file_fixture("hearing_resulted.json").read,
            )
        end

        describe "response" do
          response(200, "Success") do
            run_test!
          end
        end
      end

      context "with publish_to_queue=true" do
        let(:hearing_id) { "b935a64a-6d03-4da4-bba6-4d32cc2e7fb4" }
        let(:publish_to_queue) { true }

        parameter name: :publish_to_queue, in: :query, required: false, type: :boolean, description: "Publish hearing results to MAAT API"

        before do
          stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/hearing/results?hearingId=#{hearing_id}")
            .to_return(
              status: 200,
              headers: { content_type: "application/json" },
              body: file_fixture("hearing_resulted.json").read,
            )

          expect(HearingsCreatorWorker).to receive(:perform_async)
        end

        describe "response" do
          response(200, "Success") do
            run_test!
          end
        end
      end
    end
  end
end
