# frozen_string_literal: true

require "swagger_helper"
require "sidekiq/testing"

RSpec.describe "api/internal/v1/representation_orders", swagger_doc: "v1/swagger.yaml", type: :request do
  include AuthorisedRequestHelper

  let(:token) { access_token }
  let(:defendant_id) { SecureRandom.uuid }

  let(:offence_array) do
    [
      {
        offence_id: SecureRandom.uuid,
        status_code: "GR",
        status_date: "2020-02-12",
        effective_start_date: "2020-02-20",
        effective_end_date: "2020-02-25",
      },
    ]
  end

  let(:defence_organisation) do
    {
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
    }
  end

  let(:representation_order) do
    {
      data: {
        type: "representation_orders",
        attributes: {
          maat_reference: 1_231_231,
          defence_organisation:,
          offences: offence_array,
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

  around do |example|
    Sidekiq::Testing.fake! do
      example.run
    end
  end

  path "/api/internal/v1/representation_orders" do
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

        parameter name: :representation_order, in: :body, required: true, type: :object,
                  schema: {
                    "$ref": "representation_order.json#/definitions/new_resource",
                  },
                  description: "The Representation Order for an offence"

        parameter "$ref" => "#/components/parameters/transaction_id_header"

        let(:Authorization) { "Bearer #{token.token}" }

        before do
          expect(ProsecutionCaseRepresentationOrderCreatorWorker).to receive(:perform_async).with(
            String,
            defendant_id,
            offence_array.map { |o| o.deep_transform_keys(&:to_s) },
            1_231_231,
            defence_organisation.deep_transform_keys(&:to_s),
          ).and_call_original
        end

        run_test!
      end

      context "with an invalid maat_reference" do
        response("422", "Unprocessable entity") do
          let(:Authorization) { "Bearer #{token.token}" }
          before { representation_order[:data][:attributes][:maat_reference] = "ABC123123" }

          before do
            expect(ProsecutionCaseRepresentationOrderCreatorWorker).not_to receive(:perform_async)
          end

          run_test!
        end
      end

      context "when request is unauthorized" do
        response("401", "Unauthorized") do
          let(:Authorization) { nil }

          before do
            expect(ProsecutionCaseRepresentationOrderCreatorWorker).not_to receive(:perform_async)
          end

          run_test!
        end
      end

      context "with a failing contract" do
        before { representation_order[:data][:relationships][:defendant][:data][:id] = "foo" }

        it "renders a JSON response with an unprocessable_entity error" do
          post api_internal_v1_prosecution_case_representation_orders_path, params: representation_order, headers: { "Authorization" => "Bearer #{token.token}" }

          expect(response.body).to include("is not a valid uuid")
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
