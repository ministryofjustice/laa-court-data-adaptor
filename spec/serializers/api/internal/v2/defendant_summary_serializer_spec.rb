# frozen_string_literal: true

RSpec.describe Api::Internal::V2::DefendantSummarySerializer do
  subject { described_class.new(defendant_summary).serializable_hash }

  let(:defendant_summary_data) { JSON.parse(file_fixture("defendant_summary/all_fields.json").read) }
  let(:defendant_summary) { HmctsCommonPlatform::DefendantSummary.new(defendant_summary_data) }

  context "with attributes" do
    let(:attributes) { subject[:data][:attributes] }

    it { expect(attributes[:name]).to eq("Bob Steven Smith") }
    it { expect(attributes[:date_of_birth]).to eq("1986-11-10") }
    it { expect(attributes[:national_insurance_number]).to eq("AA123456C") }
    it { expect(attributes[:arrest_summons_number]).to eq("2100000000000267128K") }
  end
end
