require "rails_helper"
require "sidekiq/testing"
Sidekiq::Testing.fake!
RSpec.describe Api::Internal::V1::CourtApplicationRepresentationOrdersController, type: :controller do
  include AuthorisedRequestHelper

  let(:valid_params) do
    {
      data: {
        type: "representation_orders",
        attributes: {
          maat_reference: 123_456_789,
          subject_id: "51b391f8-44b1-4656-bd93-dfd1dd3b49c7",
          defence_organisation: {
            organisation: {
              name: "Dave reps order",
              address: {
                address1: "qnson",
                postcode: "ert56",
              },
            },
            laa_contract_number: "123456789",
          },
          offences: [
            {
              offence_id: "2f35101f-edca-459b-878b-3049fb3b15fc",
              status_code: "AP",
              status_date: "2025-04-07",
              effective_start_date: "2025-04-01",
              effective_end_date: "2025-04-30",
            },
          ],
        },
      },
    }
  end

  let(:request_headers) { { "Content-Type" => "application/json" } }
  let(:mock_contract) { instance_double(CourtApplicationRepresentationOrderContract) }

  before do
    authorise_requests!
    allow(CourtApplicationRepresentationOrderContract).to receive(:new).and_return(mock_contract)
  end

  context "when the contract is successful" do
    before do
      allow(mock_contract).to receive(:call).and_return(instance_double(Dry::Validation::Result, success?: true))
    end

    it "returns a 202 Accepted status" do
      post :create, params: valid_params, as: :json
      expect(response).to have_http_status(:accepted)
    end
  end

  context "when the contract fails" do
    let(:errors) { Dry::Validation::MessageSet.new([message]) }
    let(:message) { Dry::Schema::Message.new(text: "is invalid", path: [:maat_reference], predicate: :int?, input: "123") }

    before do
      allow(mock_contract).to receive(:call).and_return(
        instance_double(Dry::Validation::Result, success?: false, errors:),
      )
    end

    it "returns a 422 Unprocessable Entity status with error details" do
      post :create, params: valid_params, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("maat_reference", "is invalid")
    end
  end
end
