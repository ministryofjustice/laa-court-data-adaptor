require "rails_helper"

RSpec.describe Api::Internal::V1::CourtApplicationRepresentationOrdersController, type: :controller do
  include AuthorisedRequestHelper

  let(:transformed_params) do
    {
      maat_reference: "123456",
      subject_id: "abc123",
      defence_organisation: { name: "Test Org" },
      offences: [
        { offence_id: "off1", status_code: "A", status_date: "2023-01-01" },
      ],
    }
  end

  before do
    allow(controller).to receive(:transformed_params).and_return(transformed_params)
  end

  describe "#create_params" do
    it "permits expected parameters in create_params" do
      raw_params = {
        representation_order: {
          maat_reference: "123456",
          subject_id: "abc123",
          defence_organisation: {},
          offences: [
            {
              offence_id: "off1",
              status_code: "ACTIVE",
              status_date: "2024-04-01",
              effective_start_date: "2024-04-01",
              effective_end_date: "2024-06-01",
            },
          ],
        },
      }

      permitted_params = ActionController::Parameters.new(raw_params)
      allow(controller).to receive_message_chain(:params, :from_jsonapi).and_return(permitted_params)

      result = controller.send(:create_params)

      expect(result[:maat_reference]).to eq("123456")
      expect(result[:subject_id]).to eq("abc123")
      expect(result[:defence_organisation]).to be_a(ActionController::Parameters)
      expect(result[:defence_organisation]).to be_empty
      expect(result[:offences]).to be_an(Array)
    end
  end

  describe "#contract" do
    let(:mock_contract) { instance_double(NewCourtApplicationRepresentationOrderContract) }
    let(:mock_result) { instance_double(Dry::Validation::Result) }

    before do
      allow(NewCourtApplicationRepresentationOrderContract).to receive(:new).and_return(mock_contract)
    end

    it "calls the contract with transformed_params" do
      allow(mock_contract).to receive(:call).with(**transformed_params).and_return(mock_result)
      controller.send(:contract)
      expect(mock_contract).to have_received(:call).with(**transformed_params)
    end
  end

  describe "#enforce_contract!" do
    context "when the contract is successful" do
      it "does not raise an error" do
        fake_contract = double("Contract", success?: true)
        allow(controller).to receive(:contract).and_return(fake_contract)

        expect {
          controller.send(:enforce_contract!)
        }.not_to raise_error
      end
    end

    context "when the contract is unsuccessful" do
      it "raises a ContractError with the contract errors" do
        fake_contract = double("Contract", success?: false, errors: double(to_hash: { some: "error" }))
        allow(controller).to receive(:contract).and_return(fake_contract)

        expect {
          controller.send(:enforce_contract!)
        }.to raise_error(Errors::ContractError, /Representation Order contract failed with: {.*some.*error.*}/)
      end
    end
  end

  describe "#enqueue_representation_order" do
    it "enqueues CourtApplicationRepresentationOrderCreatorWorker with correct arguments" do
      allow(Current).to receive(:request_id).and_return("req-123")

      expect(CourtApplicationRepresentationOrderCreatorWorker).to receive(:perform_async).with(
        "req-123",
        "abc123",
        [{ offence_id: "off1", status_code: "A", status_date: "2023-01-01" }],
        "123456",
        { name: "Test Org" },
      )

      controller.send(:enqueue_representation_order)
    end
  end

  describe "#create" do
    before { authorise_requests! }

    context "when the request is valid" do
      it "calls enforce_contract!, enqueues the representation order, and responds with :accepted" do
        expect(controller).to receive(:enforce_contract!)
        expect(controller).to receive(:enqueue_representation_order)

        post :create

        expect(response).to have_http_status(:accepted)
      end
    end
  end
end
