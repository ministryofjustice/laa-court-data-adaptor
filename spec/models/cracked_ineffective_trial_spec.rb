# frozen_string_literal: true

RSpec.describe CrackedIneffectiveTrial, type: :model do
  subject(:cracked_ineffective_trial) { described_class.new(body: cracked_ineffective_trial_hash) }

  let(:cracked_ineffective_trial_hash) do
    JSON.parse(file_fixture("cracked_ineffective_trial.json").read)
  end

  describe "#id" do
    subject { cracked_ineffective_trial.id }

    it { is_expected.to eql("c4ca4238-a0b9-3382-8dcc-509a6f75849b") }
  end

  describe "#type" do
    subject(:type) { cracked_ineffective_trial.type }

    it "is expected to downcase the type" do
      expect(type).to eql("cracked")
    end
  end

  describe "#code" do
    subject { cracked_ineffective_trial.code }

    it { is_expected.to eql("A") }
  end

  describe "#description" do
    subject { cracked_ineffective_trial.description }

    it { is_expected.to eql("On the date of trial the defendant, for the first time, enters a guilty plea which the prosecution accepts.") }
  end
end
