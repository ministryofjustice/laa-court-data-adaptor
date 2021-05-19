RSpec.describe Api::Internal::V1::CourtApplicationPartySerializer do
  let(:court_application_party_data) { JSON.parse(file_fixture("court_application_party/all_fields.json").read) }
  let(:court_application_party) { HmctsCommonPlatform::CourtApplicationParty.new(court_application_party_data) }

  it "serializes" do
    expected = {
      data: {
        attributes: {
          synonym: "suspect",
        },
        id: "4f59e8d5-53d5-4175-b9b3-d46363671d03",
        type: :court_application_party,
      },
    }

    expect(described_class.new(court_application_party).serializable_hash).to eql(expected)
  end
end
