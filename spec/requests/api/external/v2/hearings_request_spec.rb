# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/external/v2/hearing_results", swagger_doc: "v2/swagger.yaml", type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }

  path "/api/external/v2/hearing_results" do
    post("post hearing") do
      description "Post Common Platform hearing data to CDA"
      consumes "application/json"
      tags "External - available to Common Platform"
      security [{ oAuth: [] }]

      response(202, "Accepted") do
        parameter name: :hearing, in: :body, required: false, type: :object,
                  schema: {
                    '$ref': "hearing_resulted.json#/definitions/new_resource",
                  },
                  description: "The minimal Hearing Resulted payload"

        let(:Authorization) { "Bearer #{token.token}" }
        let(:hearing) { JSON.parse(file_fixture("hearing/valid.json").read) }

        before do
          expect(HearingsCreatorWorker).to receive(:perform_async)
        end

        run_test!
      end

      context "when entity is unprocessable" do
        response("422", "Unprocessable Entity") do
          let(:Authorization) { "Bearer #{token.token}" }
          let(:hearing) { JSON.parse(file_fixture("hearing/unprocessable.json").read) }

          run_test!
        end
      end

      context "when data is invalid" do
        response("400", "Bad Request") do
          let(:Authorization) { "Bearer #{token.token}" }
          let(:hearing) { JSON.parse(file_fixture("hearing/invalid.json").read) }

          run_test!
        end
      end

      context "when request is unauthorized" do
        response("401", "Unauthorized") do
          let(:Authorization) { nil }

          run_test!
        end
      end
    end
  end
end
