# frozen_string_literal: true

RSpec.describe CrackedIneffectiveTrial, type: :model do
  subject(:cracked_ineffective_trial) { described_class.new(body: cracked_ineffective_trial_data) }

  context "with required fields" do
    let(:cracked_ineffective_trial_data) do
      JSON.parse(file_fixture("cracked_ineffective_trial/required_fields.json").read)
    end

    it { expect(cracked_ineffective_trial.id).to eql("c4ca4238-a0b9-3382-8dcc-509a6f75849b") }
    it { expect(cracked_ineffective_trial.type).to eql("cracked") }
    it { expect(cracked_ineffective_trial.code).to eql("A") }
    it { expect(cracked_ineffective_trial.description).to eql("On the date of trial the defendant, for the first time, enters a guilty plea which the prosecution accepts.") }
  end
end
