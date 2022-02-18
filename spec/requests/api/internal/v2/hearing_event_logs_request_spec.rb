require "swagger_helper"

RSpec.describe "api/internal/v2/hearings/{hearing_id}/event_log/{date}", type: :request, swagger_doc: "v2/swagger.yaml" do
  include AuthorisedRequestHelper

  let(:token) { access_token }

  path "/api/internal/v2/hearings/{hearing_id}/event_log/{date}" do
    get("fetch the hearing events log for a hearing") do
      description "fetch the hearing event logs for a hearing"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]

      produces "application/vnd.api+json"

      parameter name: :hearing_id,
                in: :path,
                required: true,
                type: :uuid,
                description: "The hearing UUID",
                schema: { "$ref": "hearing.json#/properties/id" }

      parameter name: :date,
                in: :path,
                type: :string,
                required: true,
                description: "The date of the hearing",
                schema: { "$ref": "definitions.json#/definitions/datePattern" }

      parameter "$ref" => "#/components/parameters/transaction_id_header"

      let(:Authorization) { "Bearer #{token.token}" }

      context "when a hearing log is found" do
        let(:hearing_id) { "2c24f897-ffc4-439f-9c4a-ec60c7715cd0" }
        let(:date) { "2020-04-29" }

        before do
          stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/hearing/hearingLog?hearingId=#{hearing_id}&date=#{date}")
            .to_return(
              status: 200,
              headers: { content_type: "application/json" },
              body: file_fixture("valid_hearing_logs.json").read,
            )
        end

        describe "responds with" do
          response(200, "Success") do
            schema "$ref" => "hearing_event_log_response.json#"
            run_test!
          end
        end
      end

      context "when unauthorized" do
        let(:hearing_id) { "c6cf04b5" }
        let(:date) { "2020-02-09" }
        let(:Authorization) { nil }

        response(401, "Unauthorized") do
          run_test!
        end
      end

      context "when no hearing log is found" do
        let(:hearing_id) { "c6cf04b5" }
        let(:date) { "2020-02-09" }

        before do
          stub_request(:get, "#{ENV['COMMON_PLATFORM_URL']}/hearing/hearingLog?hearingId=#{hearing_id}&date=#{date}")
            .to_return(
              status: 200,
              headers: { content_type: "application/json" },
              body: "{}",
            )
        end

        describe "responds with" do
          response(404, "not found") do
            run_test!
          end
        end
      end
    end
  end
end
