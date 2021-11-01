# frozen_string_literal: true

RSpec.describe HearingSummary, type: :model do
  subject(:hearing_summary) { described_class.new(body: hearing_summary_hash) }

  let(:prosecution_case_hash) do
    JSON.parse(file_fixture("prosecution_case_search_result.json").read)["cases"][0]
  end

  let(:hearing_summary_hash) do
    prosecution_case_hash["hearingSummary"][0]
  end

  it { expect(hearing_summary.id).to eq("b935a64a-6d03-4da4-bba6-4d32cc2e7fb4") }
  it { expect(hearing_summary.hearing_type).to eq("First hearing") }
  it { expect(hearing_summary.estimated_duration).to eq("20") }
  it { expect(hearing_summary.hearing_days).to all be_a(HmctsCommonPlatform::HearingDay) }
  it { expect(hearing_summary.court_centre).to be_a(HmctsCommonPlatform::CourtCentre) }
  it { expect(hearing_summary.short_oucode).to eq("B01BH") }
  it { expect(hearing_summary.oucode_l2_code).to eq("1") }
end
