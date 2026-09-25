# frozen_string_literal: true

RSpec.describe MaatApi::MaatReferenceValidator do
  subject(:validator_response) { described_class.call(maat_reference:) }

  let(:maat_reference) { 5_635_424 }

  context "with valid maat_reference" do
    before do
      stub_maat_validation("valid_maat_reference", status: 200)
    end

    it "validates a maat_reference" do
      expect(validator_response.success?).to be true
      expect(validator_response.error_code).to be_nil
    end
  end

  context "with invalid maat_reference" do
    let(:maat_reference) { 9_999_999 }

    before do
      stub_maat_validation("invalid_maat_reference", status: 400)
    end

    it "returns an error message" do
      expect(validator_response.success?).to be false
      expect(validator_response.error_code).to eq(:invalid)
    end
  end

  context "with an already linked maat_reference" do
    before do
      stub_maat_validation("already_linked_maat_reference", status: 400)
    end

    it "returns an error message" do
      expect(validator_response.success?).to be false
      expect(validator_response.error_code).to eq(:already_linked)
    end
  end

  context "with a maat_reference without common platform data" do
    before do
      stub_maat_validation("no_common_platform_data", status: 400)
    end

    it "returns an error message" do
      expect(validator_response.success?).to be false
      expect(validator_response.error_code).to eq(:no_common_platform_data)
    end
  end
end
