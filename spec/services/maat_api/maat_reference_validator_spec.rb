# frozen_string_literal: true

RSpec.describe MaatApi::MaatReferenceValidator do
  subject(:validator_response) { described_class.call(maat_reference:) }

  let(:maat_reference) { 5_635_424 }

  it "validates a maat_reference" do
    VCR.use_cassette("maat_api/maat_reference_success", tag: :maat_api) do
      expect(validator_response.status).to eq(200)
      expect(validator_response.body).to be_empty
    end
  end

  context "with invalid maat_reference" do
    let(:maat_reference) { 5_635_423 }

    it "returns an error message" do
      VCR.use_cassette("maat_api/maat_reference_invalid", tag: :maat_api) do
        expect(validator_response.status).to eq(400)
        expect(validator_response.body["message"]).to eq("5635423: MaatId already linked to the application.")
      end
    end
  end

  context "when the connection is blank" do
    subject(:call_validator) { described_class.call(maat_reference:, connection: nil) }

    it "raises an error" do
      expect { call_validator }.to raise_error("Connection is blank")
    end
  end
end
