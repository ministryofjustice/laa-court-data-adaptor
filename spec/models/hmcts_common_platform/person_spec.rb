RSpec.describe HmctsCommonPlatform::Person, type: :model do
  let(:data) { JSON.parse(file_fixture("person.json").read) }
  let(:person) { described_class.new(data) }

  it "matches the HMCTS Common Platform schema" do
    expect(data).to match_json_schema(:person)
  end

  it "generates a JSON representation of the data" do
    expect(person.to_json["title"]).to eql("Mr")
    expect(person.to_json["first_name"]).to eql("John")
    expect(person.to_json["middle_name"]).to eql("Maynard")
    expect(person.to_json["last_name"]).to eql("Smith")
    expect(person.to_json["gender"]).to eql("MALE")
    expect(person.to_json["date_of_birth"]).to eql("1965-11-30")
    expect(person.to_json["occupation"]).to eql("Unemployed")
    expect(person.to_json["occupation_code"]).to eql("6001")
  end

  it { expect(person.title).to eql("Mr") }
  it { expect(person.first_name).to eql("John") }
  it { expect(person.middle_name).to eql("Maynard") }
  it { expect(person.last_name).to eql("Smith") }
  it { expect(person.gender).to eql("MALE") }
  it { expect(person.date_of_birth).to eql("1965-11-30") }
  it { expect(person.occupation).to eql("Unemployed") }
  it { expect(person.occupation_code).to eql("6001") }
end
