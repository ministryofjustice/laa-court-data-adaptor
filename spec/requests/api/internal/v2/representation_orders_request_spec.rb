# frozen_string_literal: true

require "swagger_helper"
require "sidekiq/testing"

RSpec.describe "api/internal/v2/representation_orders", swagger_doc: "v2/swagger.yaml", type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }

  let(:representation_order) do
    {
      representation_order: {
        maat_reference: 123_456,
        defendant_id: SecureRandom.uuid,
        defence_organisation: {
          laa_contract_number: "CONTRACT REFERENCE",
          sra_number: "SRA NUMBER",
          bar_council_membership_number: "BAR COUNCIL NUMBER",
          incorporation_number: "AAA",
          registered_charity_number: "BBB",
          organisation: {
            name: "SOME ORGANISATION",
            address: {
              address1: "102",
              address2: "Petty France",
              address3: "Floor 5",
              address4: "St James",
              address5: "Westminster",
              postcode: "EC4A 2AH",
            },
            contact: {
              home: "+99999",
              work: "CALL ME 888",
              mobile: "+99999",
              primary_email: "a@example.com",
              secondary_email: "a@example.com",
              fax: "ABC123123",
            },
          },
        },
        offences: [
          {
            offence_id: SecureRandom.uuid,
            status_code: "GR",
            status_date: "2020-02-12",
            effective_start_date: "2020-02-20",
            effective_end_date: "2020-02-25",
          },
        ],
      },
    }
  end

  around do |example|
    Sidekiq::Testing.fake! do
      example.run
    end
  end

  path "/api/internal/v2/representation_orders" do
    post("post representation_order") do
      description "Post a Representation Order to CDA to update the status on a MAAT case to a Common Platform case"
      consumes "application/vnd.api+json"
      tags "Internal - available to other LAA applications"
      security [{ oAuth: [] }]

      response(202, "Accepted") do
        around do |example|
          VCR.use_cassette("representation_order_recorder/update") do
            example.run
          end
        end

        parameter name: :representation_order,
                  in: :body,
                  required: true,
                  type: :object,
                  description: "The Representation Order for an offence",
                  schema: {
                    "$ref": "representation_order_request.json#",
                  }

        parameter "$ref" => "#/components/parameters/transaction_id_header"

        let(:Authorization) { "Bearer #{token.token}" }

        before do
          expect(RepresentationOrderCreatorWorker).to receive(:perform_async).with(
            String,
            representation_order.dig(:representation_order, :defendant_id),
            representation_order.dig(:representation_order, :offences),
            representation_order.dig(:representation_order, :maat_reference),
            representation_order.dig(:representation_order, :defence_organisation),
          )
        end

        run_test!
      end

      context "with an invalid maat_reference" do
        response(422, "Unprocessable entity") do
          let(:Authorization) { "Bearer #{token.token}" }

          before do
            representation_order[:representation_order][:maat_reference] = "ABC123123"
            expect(RepresentationOrderCreatorWorker).not_to receive(:perform_async)
          end

          run_test!
        end
      end

      context "when request is unauthorized" do
        response(401, "Unauthorized") do
          let(:Authorization) { nil }

          before do
            expect(RepresentationOrderCreatorWorker).not_to receive(:perform_async)
          end

          run_test!
        end
      end

      context "with a failing contract" do
        before { representation_order[:representation_order][:defendant_id] = 123 }

        it "renders a JSON response with an unprocessable_entity error" do
          post "/api/internal/v2/representation_orders", params: representation_order, headers: { "Authorization" => "Bearer #{token.token}" }

          expect(response.body).to include("is not a valid uuid")
          expect(response.parsed_body["error_codes"]).to eq %w[maat_reference_contract_failure defendant_id_contract_failure]
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
