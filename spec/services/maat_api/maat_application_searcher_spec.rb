# frozen_string_literal: true

RSpec.describe MaatApi::MaatApplicationSearcher do
  subject(:search_response) { described_class.call(**criteria) }

  before { stub_maat_api_token }

  context "when there are multiple matches" do
    let(:criteria) { { first_name: "Tango", last_name: "JF-LAA-T" } }

    before { stub_maat_search("multiple_results") }

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

  context "when search criteria have blank values" do
    let(:criteria) do
      { first_name: "Tango",
        last_name: "JF-LAA-T",
        date_of_birth: nil,
        arrest_summons_number: "",
        committal_date: "" }
    end

    before { stub_maat_search("success") }

    it "omits them from the search request" do
      search_response

      expect(
        a_request(:post, maat_search_url).with(body: { firstName: "Tango", lastName: "JF-LAA-T" }),
      ).to have_been_made
    end
  end

  context "when there is no matching maat application" do
    let(:criteria) { { first_name: "nonexistent-first-name", last_name: "nonexistent-last-name" } }

    before { stub_maat_search("not_found", status: 404) }

    it "returns a not found error" do
      expect(search_response.status).to eq(404)
      expect(search_response.body).to eq("code" => "NOT_FOUND", "message" => "Representation order not found")
    end
  end

  context "when firstName is not specified" do
    let(:criteria) { { last_name: "JF-LAA-T" } }

    before { stub_maat_search("bad_request", status: 400, content_type: "application/problem+json") }

    it "returns an unparsed bad request error" do
      expect(search_response.status).to eq(400)
      expect(search_response.body).to include("Invalid request content.")
    end
  end
end
