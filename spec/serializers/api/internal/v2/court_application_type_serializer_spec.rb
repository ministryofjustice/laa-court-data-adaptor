RSpec.describe Api::Internal::V2::CourtApplicationTypeSerializer do
  let(:court_application_type_data) { JSON.parse(file_fixture("court_application_type/all_fields.json").read) }
  let(:court_application_type) { HmctsCommonPlatform::CourtApplicationType.new(court_application_type_data) }

  it "serializes court application type data" do
    expected = {
      data: {
        attributes: {
          applicant_appellant_flag: false,
          category_code: "CO",
          code: "LA12505",
          description: "Application for transfer of legal aid",
          id: "74b72f6f-414a-3464-a4a2-d91397b4c439",
          legislation: "Pursuant to Regulation 14 of the Criminal Legal Aid",
        },
        id: "74b72f6f-414a-3464-a4a2-d91397b4c439",
        type: :court_application_type,
      },
    }

    expect(described_class.new(court_application_type).serializable_hash).to eql(expected)
  end
end
