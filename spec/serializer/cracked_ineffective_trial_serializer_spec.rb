# frozen_string_literal: true

RSpec.describe CrackedIneffectiveTrialSerializer do
  subject { described_class.new(cracked_ineffective_trial).serializable_hash }

  let(:cracked_ineffective_trial) do
    instance_double("CrackedIneffectiveTrial",
                    id: "a-uuid",
                    code: "A",
                    type: "cracked",
                    description: "A reason for the cracked trail goes here")
  end

  context "with attributes" do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:id]).to eq("a-uuid") }
    it { expect(attribute_hash[:code]).to eq("A") }
    it { expect(attribute_hash[:type]).to eq("cracked") }
    it { expect(attribute_hash[:description]).to eq("A reason for the cracked trail goes here") }
  end
end
