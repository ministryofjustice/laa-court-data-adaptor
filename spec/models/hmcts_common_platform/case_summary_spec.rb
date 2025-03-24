RSpec.describe HmctsCommonPlatform::CaseSummary, type: :model do
  let(:case_summary) { described_class.new(data) }
  let(:data) { JSON.parse(file_fixture("case_summary.json").read) }

  it "generates a JSON representation of the data" do
    expect(case_summary.to_json["case_status"]).to eql("INACTIVE")
    expect(case_summary.to_json["prosecution_case_id"]).to eql("33ef3cfe-b2c3-4694-9ccb-0ebfbd0d2564")
    expect(case_summary.to_json["prosecution_case_reference"]).to eql("29GD7216523")
  end

  it { expect(case_summary.case_status).to eql("INACTIVE") }
  it { expect(case_summary.prosecution_case_id).to eql("33ef3cfe-b2c3-4694-9ccb-0ebfbd0d2564") }
  it { expect(case_summary.prosecution_case_reference).to eql("29GD7216523") }
end
