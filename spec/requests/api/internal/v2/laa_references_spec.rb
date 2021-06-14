# frozen_string_literal: true

require "swagger_helper"
require "sidekiq/testing"

RSpec.describe "api/internal/v2/laa_references", type: :request, swagger_doc: "v2/swagger.yaml" do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:defendant_id) { SecureRandom.uuid }
  let(:laa_reference) do
    {
      data: {
        type: "laa_references",
        attributes: {
          maat_reference: 1_231_231,
          user_name: "JaneDoe",
          unlink_reason_code: 1,
          unlink_other_reason_text: "",
        },
        relationships: {
          defendant: {
            data: {
              type: "defendants",
              id: defendant_id,
            },
          },
        },
      },
    }
  end

  before do
    allow(Current).to receive(:request_id).and_return("XYZ")
    allow(LinkValidator).to receive(:call).and_return(true)
  end

  around do |example|
    VCR.use_cassette("maat_api/maat_reference_success") do
      Sidekiq::Testing.fake! do
        example.run
      end
    end
  end

  path "/api/internal/v2/laa_references" do
    post("post laa_reference") do
      description "Post an LAA reference to CDA to link a MAAT case to a Common Platform case"
      consumes "application/json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]

      response(202, "Accepted") do
        around do |example|
          Sidekiq::Testing.fake!
          VCR.use_cassette("laa_reference_recorder/update") do
            example.run
          end
        end

        parameter name: :laa_reference, in: :body, required: false, type: :object,
                  schema: {
                    '$ref': "laa_reference.json#/definitions/new_resource",
                  },
                  description: "The LAA issued reference to the application. CDA expects a numeric number, although HMCTS allows strings"

        parameter "$ref" => "#/components/parameters/transaction_id_header"

        let(:Authorization) { "Bearer #{token.token}" }

        before do
          expect(MaatLinkCreatorWorker).to receive(:perform_async)
            .with("XYZ", defendant_id, "JaneDoe", 1_231_231)
        end

        run_test!
      end

      context "with a blank maat_reference" do
        response(202, "Accepted") do
          let(:Authorization) { "Bearer #{token.token}" }

          parameter "$ref" => "#/components/parameters/transaction_id_header"

          before do
            laa_reference[:data][:attributes].delete(:maat_reference)

            expect(MaatLinkCreatorWorker).to receive(:perform_async)
              .with("XYZ", defendant_id, "JaneDoe", nil)
          end

          run_test!
        end
      end

      context "with a blank user_name" do
        response("422", "Unprocessable entity") do
          let(:Authorization) { "Bearer #{token.token}" }

          parameter "$ref" => "#/components/parameters/transaction_id_header"

          before do
            laa_reference[:data][:attributes].delete(:user_name)
            expect(MaatLinkCreatorWorker).not_to receive(:perform_async)
          end

          run_test!
        end
      end

      context "with an invalid maat_reference" do
        response("422", "Unprocessable entity") do
          let(:Authorization) { "Bearer #{token.token}" }
          before { laa_reference[:data][:attributes][:maat_reference] = "ABC123123" }

          parameter "$ref" => "#/components/parameters/transaction_id_header"

          before do
            expect(MaatLinkCreatorWorker).not_to receive(:perform_async)
          end

          run_test!
        end
      end

      context "when request is unauthorized" do
        response("401", "Unauthorized") do
          let(:Authorization) { nil }

          parameter "$ref" => "#/components/parameters/transaction_id_header"

          before do
            expect(MaatLinkCreatorWorker).not_to receive(:perform_async)
          end

          run_test!
        end
      end

      context "with a failing LAA Reference contract" do
        before { laa_reference[:data][:relationships][:defendant][:data][:id] = "foo" }

        it "renders a JSON response with an unprocessable_entity error" do
          post api_internal_v2_laa_references_path, params: laa_reference, headers: { "Authorization" => "Bearer #{token.token}" }

          expect(response.body).to include("is not a valid uuid")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
