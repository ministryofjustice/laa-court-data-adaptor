# frozen_string_literal: true

RSpec.describe MaatApi::MaatReferenceValidator do
  subject(:validator_response) { described_class.call(maat_reference:) }

  context "with valid maat_reference" do
    let(:maat_reference) { 5_635_424 }

    before do
      stub_maat_validation("valid_maat_reference", status: 200)
    end

    it "validates a maat_reference" do
      expect(validator_response.status).to eq(200)
      expect(validator_response.body).to be_empty
    end
  end

  context "with invalid maat_reference" do
    let(:maat_reference) { 9_999_999 }

    before do
      stub_maat_validation("invalid_maat_reference", status: 400)
    end

    it "returns an error message" do
      expect(validator_response.status).to eq(400)
      expect(validator_response.body["message"]).to eq("MAAT/REP ID [9999999] is invalid")
    end
  end
end
