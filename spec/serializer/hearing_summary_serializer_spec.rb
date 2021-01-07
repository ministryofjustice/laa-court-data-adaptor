# frozen_string_literal: true

RSpec.describe HearingSummarySerializer do
  subject { described_class.new(hearing_summary).serializable_hash }

  let(:hearing_summary) do
    instance_double("HearingSummary",
                    id: "UUID",
                    hearing_type: "Committal for Sentencing",
                    hearing_days: %w[2020-02-01])
  end

  context "with attributes" do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:hearing_type]).to eq("Committal for Sentencing") }
    it { expect(attribute_hash[:hearing_days]).to eq(%w[2020-02-01]) }
  end
end
