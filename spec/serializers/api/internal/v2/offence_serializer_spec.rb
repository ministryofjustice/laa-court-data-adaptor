# frozen_string_literal: true

RSpec.describe Api::Internal::V2::OffenceSerializer do
  subject { described_class.new(offence).serializable_hash }

  let(:offence) do
    instance_double("Offence",
                    id: "UUID",
                    code: "AA06001",
                    order_index: "0",
                    title: "Fail to wear protective clothing",
                    legislation: "Offences against the Person Act 1861 s.24",
                    mode_of_trial: "Indictable-Only Offence",
                    mode_of_trial_reasons: [{ description: "Court directs trial by jury", code: "5" }],
                    pleas: %w[GUILTY NOT_GUILTY])
  end

  context "with attributes" do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:code]).to eq("AA06001") }
    it { expect(attribute_hash[:order_index]).to eq("0") }
    it { expect(attribute_hash[:title]).to eq("Fail to wear protective clothing") }
    it { expect(attribute_hash[:legislation]).to eq("Offences against the Person Act 1861 s.24") }
    it { expect(attribute_hash[:mode_of_trial]).to eq("Indictable-Only Offence") }
    it { expect(attribute_hash[:mode_of_trial_reasons]).to eq([{ description: "Court directs trial by jury", code: "5" }]) }
    it { expect(attribute_hash[:pleas]).to eq(%w[GUILTY NOT_GUILTY]) }
  end
end
