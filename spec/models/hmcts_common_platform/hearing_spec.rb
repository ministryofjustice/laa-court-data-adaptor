RSpec.describe HmctsCommonPlatform::Hearing, type: :model do
  let(:data) { JSON.parse(file_fixture("hearing/all_fields.json").read) }
  let(:hearing) { described_class.new(data) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:hearing)
  end

  it "generates a JSON representation of the data" do
    expect(hearing.to_json["id"]).to eql("b935a64a-6d03-4da4-bba6-4d32cc2e7fb4")
    expect(hearing.to_json["has_shared_results"]).to be false
    expect(hearing.to_json["hearing_language"]).to eql("WELSH")
    expect(hearing.to_json["hearing_type"]).to be_present
    expect(hearing.to_json["court_centre"]).to be_present
    expect(hearing.to_json["jurisdiction_type"]).to eql("CROWN")
    expect(hearing.to_json["cracked_ineffective_trial"]).to be_present
    expect(hearing.to_json["hearing_days"]).to be_present
    expect(hearing.to_json["prosecution_cases"]).to be_present
    expect(hearing.to_json["court_applications"]).to be_present
    expect(hearing.to_json["prosecution_counsels"]).to be_present
    expect(hearing.to_json["defence_counsels"]).to be_present
    expect(hearing.to_json["respondent_counsels"]).to eq []
    expect(hearing.to_json["applicant_counsels"]).to eq []
    expect(hearing.to_json["judiciary"]).to be_present
    expect(hearing.to_json["defendant_judicial_results"]).to be_present
    expect(hearing.to_json["defendant_attendance"]).to be_present
  end

  it { expect(hearing.id).to eql("b935a64a-6d03-4da4-bba6-4d32cc2e7fb4") }
  it { expect(hearing.has_shared_results).to be false }
  it { expect(hearing.language).to eql("WELSH") }
  it { expect(hearing.jurisdiction_type).to eql("CROWN") }
  it { expect(hearing.court_centre_id).to eql("bc4864ca-4b22-3449-9716-a8db1db89905") }
  it { expect(hearing.first_sitting_day_date).to eql("2019-10-25T10:45:00.000Z") }
  it { expect(hearing.prosecution_cases).to all be_an(HmctsCommonPlatform::ProsecutionCase) }
  it { expect(hearing.court_applications).to all be_an(HmctsCommonPlatform::CourtApplication) }
  it { expect(hearing.judicial_roles).to all be_an(HmctsCommonPlatform::JudicialRole) }
  it { expect(hearing.prosecution_counsels).to all be_an(HmctsCommonPlatform::ProsecutionCounsel) }
  it { expect(hearing.defence_counsels).to all be_an(HmctsCommonPlatform::DefenceCounsel) }
  it { expect(hearing.defendant_judicial_results).to all be_an(HmctsCommonPlatform::DefendantJudicialResult) }
  it { expect(hearing.hearing_days).to all be_an(HmctsCommonPlatform::HearingDay) }
  it { expect(hearing.hearing_type).to be_an(HmctsCommonPlatform::HearingType) }
  it { expect(hearing.cracked_ineffective_trial).to be_an(HmctsCommonPlatform::CrackedIneffectiveTrial) }
  it { expect(hearing.court_centre).to be_an(HmctsCommonPlatform::CourtCentre) }
  it { expect(hearing.defendant_attendance).to all be_an(HmctsCommonPlatform::DefendantAttendance) }
end
