# frozen_string_literal: true

RSpec.describe Api::Internal::V2::HearingSummarySerializer do
  let(:serialized_data) do
    hearing_summary_data = JSON.parse(file_fixture("hearing_summary/all_fields.json").read)
    hearing_summary = HearingSummary.new(body: hearing_summary_data)

    described_class.new(hearing_summary).serializable_hash[:data]
  end

  context "with attributes" do
    let(:attributes) { serialized_data[:attributes] }

    it { expect(attributes[:hearing_type]).to eq("First hearing") }
    it { expect(attributes[:hearing_days]).to eq([{ has_shared_results: true, sitting_day: "2021-03-25" }]) }
    it { expect(attributes[:court_centre][:name]).to eq("Derby Justice Centre (aka Derby St Mary Adult)") }
    it { expect(attributes[:estimated_duration]).to eq("20") }
  end

  context "with relationships" do
    let(:relationships) { serialized_data[:relationships] }

    it { expect(relationships[:defence_counsels][:data]).to eq([{ id: "e84facce-a2df-4e57-bfe3-f5cd48c43ddc", type: :defence_counsel }]) }
  end
end
