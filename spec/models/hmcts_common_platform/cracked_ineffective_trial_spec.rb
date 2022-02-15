RSpec.describe HmctsCommonPlatform::CrackedIneffectiveTrial, type: :model do
  let(:cracked_ineffective_trial) { described_class.new(data) }
  let(:data) { JSON.parse(file_fixture("cracked_ineffective_trial/all_fields.json").read) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:cracked_ineffective_trial)
  end

  it "generates a JSON representation of the data" do
    expect(cracked_ineffective_trial.to_json["id"]).to eql("c4ca4238-a0b9-3382-8dcc-509a6f75849b")
    expect(cracked_ineffective_trial.to_json["code"]).to eql("A")
    expect(cracked_ineffective_trial.to_json["description"]).to eql("On the date of trial the defendant enters a guilty plea.")
    expect(cracked_ineffective_trial.to_json["type"]).to eql("Cracked")
    expect(cracked_ineffective_trial.to_json["date"]).to eql("2021-06-01")
  end

  it { expect(cracked_ineffective_trial.id).to eql("c4ca4238-a0b9-3382-8dcc-509a6f75849b") }
  it { expect(cracked_ineffective_trial.code).to eql("A") }
  it { expect(cracked_ineffective_trial.description).to eql("On the date of trial the defendant enters a guilty plea.") }
  it { expect(cracked_ineffective_trial.type).to eql("Cracked") }
  it { expect(cracked_ineffective_trial.date).to eql("2021-06-01") }
end
