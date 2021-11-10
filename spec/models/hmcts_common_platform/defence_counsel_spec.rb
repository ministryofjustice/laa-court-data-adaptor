RSpec.describe HmctsCommonPlatform::DefenceCounsel, type: :model do
  let(:data) { JSON.parse(file_fixture("defence_counsel/all_fields.json").read) }
  let(:defence_counsel) { described_class.new(data) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:defence_counsel)
  end

  it "has an id" do
    expect(defence_counsel.id).to eql("e84facce-a2df-4e57-bfe3-f5cd48c43ddc")
  end

  it "has a title" do
    expect(defence_counsel.title).to eql("Mr.")
  end

  it "has a first_name" do
    expect(defence_counsel.first_name).to eql("Francis")
  end

  it "has a middle_name" do
    expect(defence_counsel.middle_name).to eql("Scott")
  end

  it "has a last_name" do
    expect(defence_counsel.last_name).to eql("Fitzgerald")
  end

  it "has a status" do
    expect(defence_counsel.status).to eql("status")
  end

  it "has attendance_days" do
    expect(defence_counsel.attendance_days).to eql(%w[2018-10-25])
  end

  it "has defendants" do
    expect(defence_counsel.defendants).to eql(%w[baff62ee-ae6e-4f6a-92f8-063a1269453c])
  end
end
