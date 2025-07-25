RSpec.describe CourtApplicationLinkValidator do
  subject(:link_validator_response) { described_class.call(subject_id:) }

  let(:subject_id) { "8cd0ba7e-df89-45a3-8c61-4008a2186d64" }
  let(:court_application_id) { "7a0c947e-97b4-4c5a-ae6a-26320afc914d" }
  let!(:court_application) do
    CourtApplication.create!(
      id: court_application_id,
      subject_id:,
      body: JSON.parse(file_fixture("court_application_summary.json").read),
    )
  end

  it "returns true" do
    expect(link_validator_response).to be true
  end

  context "when the hearing summary does not exist" do
    before do
      court_application.body.delete("hearingSummary")
      court_application.save!
    end

    it "returns false" do
      expect(link_validator_response).to be false
    end
  end
end
