RSpec.describe CommonPlatform::Api::CourtApplicationSearcher do
  let(:application_id) { "00004c9f-af9f-401a-b88b-78a4f0e08163" }

  context "with an incorrect key" do
    subject(:search) { described_class.call(application_id:) }

    before do
      connection.headers["Ocp-Apim-Subscription-Key"] = "INCORRECT KEY"
    end

    it "returns an unauthorised response" do
      VCR.use_cassette("court_application_searcher/unauthorised") do
        expect(search.status).to eq(401)
      end
    end
  end

  context "when looking up an application" do
    subject(:search) { described_class.call(application_id:) }

    it "returns a successful response" do
      VCR.use_cassette("court_application_searcher/success") do
        expect(search.status).to eq(200)
        expect(search.body["applicationId"]).to eq(application_id)
        search
      end
    end
  end
end
