# frozen_string_literal: true

RSpec.describe Api::Internal::V1::CrackedIneffectiveTrialSerializer do
  subject { described_class.new(cracked_ineffective_trial).serializable_hash }

  let(:cracked_ineffective_trial) do
    instance_double(CrackedIneffectiveTrial,
                    id: "a-uuid",
                    code: "A",
                    type: "cracked",
                    description: "A reason for the cracked trail goes here")
  end

  let(:attributes) { subject[:data][:attributes] }

  it { expect(attributes[:id]).to eq("a-uuid") }
  it { expect(attributes[:code]).to eq("A") }
  it { expect(attributes[:type]).to eq("cracked") }
  it { expect(attributes[:description]).to eq("A reason for the cracked trail goes here") }
end
