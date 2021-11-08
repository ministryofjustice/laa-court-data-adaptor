# frozen_string_literal: true

RSpec.describe Api::Internal::V1::HearingSummarySerializer do
  subject(:attributes_hash) { described_class.new(hearing_summary).serializable_hash[:data][:attributes] }

  let(:hearing_summary_data) { JSON.parse(file_fixture("hearing_summary/all_fields.json").read) }
  let(:hearing_summary) { HearingSummary.new(body: hearing_summary_data) }

  it { expect(attributes_hash[:hearing_type]).to eq("First hearing") }
  it { expect(attributes_hash[:hearing_days]).to eq(%w[2021-03-25]) }
  it { expect(attributes_hash[:court_centre][:name]).to eq("Derby Justice Centre (aka Derby St Mary Adult)") }
  it { expect(attributes_hash[:estimated_duration]).to eq("20") }
end
