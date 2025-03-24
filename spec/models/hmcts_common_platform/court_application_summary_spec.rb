RSpec.describe HmctsCommonPlatform::CourtApplicationSummary, type: :model do
  let(:court_application_summary) { described_class.new(data) }
  let(:data) { JSON.parse(file_fixture("court_application_summary.json").read) }

  it "generates a JSON representation of the data" do
    expect(court_application_summary.as_json[:application_id]).to eql("00004c9f-af9f-401a-b88b-78a4f0e08163")
    expect(court_application_summary.as_json[:application_reference]).to eql("29GD7216523")
    expect(court_application_summary.as_json[:application_status]).to eql("FINALISED")
    expect(court_application_summary.as_json[:application_title]).to eql("Appeal against conviction by a Magistrates' Court to the Crown Court")
    expect(court_application_summary.as_json[:application_type]).to eql("Appeal against conviction by a Magistrates' Court to the Crown Court")
    expect(court_application_summary.as_json[:received_date]).to eql("2023-06-27")
    expect(court_application_summary.as_json[:case_summary]).to be_a(Array)
    expect(court_application_summary.as_json[:hearing_summary]).to be_a(Array)
    expect(court_application_summary.as_json[:subject_summary]).to be_a(Array)
  end

  it { expect(court_application_summary.application_id).to eql("00004c9f-af9f-401a-b88b-78a4f0e08163") }
  it { expect(court_application_summary.application_reference).to eql("29GD7216523") }
  it { expect(court_application_summary.application_status).to eql("FINALISED") }
  it { expect(court_application_summary.application_title).to eql("Appeal against conviction by a Magistrates' Court to the Crown Court") }
  it { expect(court_application_summary.application_type).to eql("Appeal against conviction by a Magistrates' Court to the Crown Court") }
  it { expect(court_application_summary.received_date).to eql("2023-06-27") }
  it { expect(court_application_summary.case_summary.first).to be_a(HmctsCommonPlatform::CaseSummary) }
  it { expect(court_application_summary.hearing_summary.first).to be_a(HmctsCommonPlatform::HearingSummary) }
  it { expect(court_application_summary.subject_summary.first).to be_a(HmctsCommonPlatform::SubjectSummary) }
end
