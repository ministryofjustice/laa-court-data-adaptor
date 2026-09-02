# frozen_string_literal: true

RSpec.describe MaatApi::MaatApplicationSearcher do
  subject(:search_response) { described_class.call(**criteria) }

  around do |example|
    VCR.use_cassette(cassette,
                     tag: :maat_api,
                     match_requests_on: %i[method uri body]) do
      example.run
    end
  end

  context "when there are multiple matches" do
    let(:cassette) { "maat_api/search_maat_application_multiple_results" }
    let(:criteria) { { first_name: "Tango", last_name: "JF-LAA-T" } }

    it "returns the matching maat applications" do
      expect(search_response.status).to eq(200)
      expect(search_response.body.map { |application| application["maatId"] }).to eq([6_559_879, 6_672_961, 6_541_616])
    end

    it "returns the linking detail of a linked maat application" do
      expect(search_response.body.last).to include(
        "isLinked" => true,
        "linkingDetail" => include("libraId" => "CP665948", "caseUrn" => "CEXOFJTQ2F"),
      )
    end

    it "returns no linking detail for an unlinked maat application" do
      expect(search_response.body.first).to include("isLinked" => false, "linkingDetail" => nil)
    end
  end

  context "when there is no matching maat application" do
    let(:cassette) { "maat_api/search_maat_application_not_found" }
    let(:criteria) { { first_name: "nonexistent-first-name", last_name: "nonexistent-last-name" } }

    it "returns a not found error" do
      expect(search_response.status).to eq(404)
      expect(search_response.body).to eq("code" => "NOT_FOUND", "message" => "Representation order not found")
    end
  end

  context "when firstName is not specified" do
    let(:cassette) { "maat_api/search_maat_application_missing_bad_request" }
    let(:criteria) { { last_name: "JF-LAA-T" } }

    it "returns an unparsed bad request error" do
      expect(search_response.status).to eq(400)
      expect(search_response.body).to include("Invalid request content.")
    end
  end
end
