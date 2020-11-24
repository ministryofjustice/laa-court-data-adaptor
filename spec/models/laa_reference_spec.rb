# frozen_string_literal: true

require "rails_helper"

RSpec.describe LaaReference, type: :model do
  let(:laa_reference) { described_class.new(defendant_id: SecureRandom.uuid, user_name: "johnDoe", maat_reference: "A12345") }
  subject { laa_reference }

  describe "validations" do
    it { should validate_presence_of(:defendant_id) }
    it { should validate_presence_of(:maat_reference) }
    it { should validate_presence_of(:user_name) }
    it { should validate_uniqueness_of(:maat_reference) }
  end

  context "when an LaaReference is no longer linked" do
    before do
      described_class.create!(defendant_id: SecureRandom.uuid, user_name: "johnDoe", maat_reference: "A12345", linked: false)
    end

    it { is_expected.to be_valid }
  end
end
