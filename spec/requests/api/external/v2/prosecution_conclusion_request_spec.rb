# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "api/external/v2/prosecution_conclusions", swagger_doc: "v2/swagger.yaml", type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }

  path "/api/external/v2/prosecution_conclusions" do
    post("post prosecution conclusion") do
      description "Post Common Platform prosecution concluded data to CDA"
      consumes "application/json"
      tags "External - available to Common Platform"
      security [{ oAuth: [] }]

      let(:Authorization) { "Bearer #{token.token}" }

      context "when sending a valid payload" do
        before do
          LaaReference.create!(
            user_name: "test-user",
            defendant_id: "67d948d1-1792-4565-a522-8ab2425827e8",
            maat_reference: "700111",
            linked: true,
          )

          expected_message = prosecution_conclusion["prosecutionConcluded"].first.merge("maatId" => "700111")

          expect(Sqs::MessagePublisher).to receive(:call)
            .once
            .with(
              message: expected_message,
              queue_url: Rails.configuration.x.aws.sqs_url_prosecution_concluded,
              log_info: { maat_reference: "700111" },
            )
        end

        context "when sending a valid prosecution case payload" do
          let(:prosecution_conclusion) { JSON.parse(file_fixture("prosecution_conclusion/valid.json").read) }

          response(202, "Accepted") do
            parameter name: :prosecution_conclusion,
                      in: :body,
                      required: true,
                      type: :object,
                      schema: { "$ref" => "prosecution_concluded_request.json#/definitions/resource" },
                      description: "The minimal prosecution concluded payload"
            run_test!
          end
        end

        context "when sending a valid application case payload" do
          let(:prosecution_conclusion) { JSON.parse(file_fixture("application_conclusion/valid.json").read) }

          response(202, "Accepted") do
            parameter name: :prosecution_conclusion,
                      in: :body,
                      required: true,
                      type: :object,
                      schema: { "$ref" => "prosecution_concluded_request.json#/definitions/resource" },
                      description: "The court application concluded payload"
            run_test!
          end
        end
      end

      context "when entity is unprocessable" do
        let(:prosecution_conclusion) { JSON.parse(file_fixture("prosecution_conclusion/unprocessable.json").read) }

        response("422", "Unprocessable Entity") do
          let(:Authorization) { "Bearer #{token.token}" }

          run_test!
        end
      end

      context "when data is invalid" do
        response("400", "Bad Request") do
          let(:Authorization) { "Bearer #{token.token}" }
          let(:prosecution_conclusion) { JSON.parse(file_fixture("prosecution_conclusion/invalid.json").read) }

          run_test!
        end
      end

      context "when request is unauthorized" do
        response("401", "Unauthorized") do
          let(:prosecution_conclusion) {}
          let(:Authorization) { nil }

          run_test!
        end
      end
    end
  end
end
