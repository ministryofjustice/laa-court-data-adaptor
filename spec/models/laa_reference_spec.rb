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

  describe "validate unlink_other_reason_text" do
    it "validates that unlink_other_reason_text is present when unlink_reason_code is 7" do
      pending "Disabled temporarily while we collect data into sentry to investigate issue"

      laa_reference.unlink_reason_code = 7
      laa_reference.unlink_other_reason_text = ""

      expect(laa_reference).not_to be_valid
      expect(laa_reference.errors).to include(:unlink_other_reason_text)
    end
  end

  describe "adjust_link_and_save!" do
    context "when there are existing laa ref" do
      let(:laa_ref1) do
        described_class.create(user_name: "AAA",
                               maat_reference: laa_reference.maat_reference,
                               linked: false,
                               created_at: 2.days.ago,
                               defendant_id: SecureRandom.uuid)
      end

      let(:laa_ref2) do
        described_class.create(user_name: "BBB",
                               maat_reference: laa_reference.maat_reference,
                               linked: true,
                               created_at: 1.day.ago,
                               defendant_id: SecureRandom.uuid)
      end

      before do
        laa_ref1
        laa_ref2
      end

      it "unlink the most recent laa ref" do
        laa_reference.linked = false

        laa_reference.adjust_link_and_save!

        expect(laa_ref2.reload.linked).to be(false)
        expect(laa_reference.linked).to be(true)
      end
    end

    context "when there are NOT existing laa ref" do
      it "unlink the most recent laa ref" do
        laa_reference.linked = false

        laa_reference.adjust_link_and_save!

        expect(laa_reference.linked).to be(true)
      end
    end

    context "when raises an ActiveRecord error" do
      # This allows to capture the exception and to prevent Sidekiq to retry N times.

      it "reports to Sentry" do
        laa_reference.defendant_id = nil

        expect(Sentry).to receive(:capture_exception).with(ActiveRecord::ActiveRecordError)

        laa_reference.adjust_link_and_save!
      end
    end
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

    it "returns true when MAAT reference is an unlinking dummy maat reference" do
      expect(described_class.new(maat_reference: "Z123")).to be_dummy_maat_reference
    end

    it "returns false when MAAT reference is a legitimate one" do
      expect(described_class.new(maat_reference: "GH12345")).not_to be_dummy_maat_reference
    end

    it "returns false when MAAT reference is nil" do
      expect(described_class.new(maat_reference: nil)).not_to be_dummy_maat_reference
    end
  end

  describe ".retrieve_by_defendant_id_and_optional_maat_reference" do
    before { laa_reference.save! }

    context "when only defendant id provided" do
      subject(:retrieved_laa_reference) { described_class.retrieve_by_defendant_id_and_optional_maat_reference(defendant_id) }

      context "when defendant ID matches" do
        let(:defendant_id) { laa_reference.defendant_id }

        it { expect(retrieved_laa_reference).to eq laa_reference }
      end

      context "when defendant ID does not match" do
        let(:defendant_id) { "456" }

        it "raises an appropriate error message" do
          expect { retrieved_laa_reference }.to raise_error(
            ActiveRecord::RecordNotFound,
            "LAA reference with defendant_id: '456' not found or already unlinked!",
          )
        end
      end
    end

    context "when both args provided" do
      subject(:retrieved_laa_reference) { described_class.retrieve_by_defendant_id_and_optional_maat_reference(defendant_id, maat_reference) }

      context "when args match" do
        let(:defendant_id) { laa_reference.defendant_id }
        let(:maat_reference) { laa_reference.maat_reference }

        it { expect(retrieved_laa_reference).to eq laa_reference }
      end

      context "when args not match" do
        let(:defendant_id) { "123" }
        let(:maat_reference) { "1234567" }

        it "raises an appropriate error message" do
          expect { retrieved_laa_reference }.to raise_error(
            ActiveRecord::RecordNotFound,
            "LAA reference with defendant_id: '123' and maat_reference: '1234567' not found or already unlinked!",
          )
        end
      end
    end
  end
end
