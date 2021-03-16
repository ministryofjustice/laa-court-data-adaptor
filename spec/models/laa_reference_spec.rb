# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaaReference, type: :model do
  subject { laa_reference }

  let(:laa_reference) { described_class.new(defendant_id: SecureRandom.uuid, user_name: "johnDoe", maat_reference: "A12345") }

  describe "validations" do
    it { is_expected.to validate_presence_of(:defendant_id) }
    it { is_expected.to validate_presence_of(:maat_reference) }
    it { is_expected.to validate_presence_of(:user_name) }
    it { is_expected.to validate_uniqueness_of(:maat_reference) }
  end

  context "when an LaaReference is no longer linked" do
    before do
      described_class.create!(defendant_id: SecureRandom.uuid, user_name: "johnDoe", maat_reference: "A12345", linked: false)
    end

    it { is_expected.to be_valid }
  end

  describe ".generate_linking_dummy_maat_reference" do
    it "starts with an A" do
      dummy_maat_reference = described_class.generate_linking_dummy_maat_reference
      expect(dummy_maat_reference).to start_with("A")
    end
  end

  describe ".generate_unlinking_dummy_maat_reference" do
    it "starts with an Z" do
      dummy_maat_reference = described_class.generate_unlinking_dummy_maat_reference
      expect(dummy_maat_reference).to start_with("Z")
    end
  end

  describe "#dummy_maat_reference?" do
    it "returns true when MAAT reference is a linking dummy maat reference" do
      expect(described_class.new(maat_reference: "A123")).to be_dummy_maat_reference
    end

    it "returns true when MAAT reference is a unlinking dummy maat reference" do
      expect(described_class.new(maat_reference: "Z123")).to be_dummy_maat_reference
    end
  end
end
