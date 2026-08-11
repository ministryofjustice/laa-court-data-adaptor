require "rails_helper"

RSpec.describe ProcessXhibitCases do
  subject(:process_cases) { described_class.call }

  shared_context "with maat api cassette" do
    around do |example|
      VCR.use_cassette(cassette,
                       tag: :maat_api,
                       match_requests_on: %i[method uri]) do
        example.run
      end
    end
  end

  context "when there is no matching maat application" do
    include_context "with maat api cassette"

    let(:cassette) { "maat_api/search_maat_application_not_found" }
    let!(:xhibit_case) { create_case(first_name: "nonexistent-first-name", last_name: "nonexistent-last-name") }

    before { process_cases }

    it "sets status to (manual) action_required" do
      expect(xhibit_case.reload).to be_action_required
    end

    it "stores a message on the case" do
      expect(xhibit_case.reload.process_errors).to eq(
        "message" => "MAAT application not found",
      )
    end
  end

  context "when there is a matching maat application" do
    include_context "with maat api cassette"

    let(:cassette) { "maat_api/search_maat_application_success" }
    let(:xhibit_case) { create_case(first_name: "Tango", last_name: "JF-LAA-T") }

    it "process - WIP", skip: "processing a matching maat application is not implemented yet" do
      process_cases
    end
  end

  context "when the search fails" do
    let!(:xhibit_case) { create_case(first_name: "Tango", last_name: "JF-LAA-T") }

    before do
      allow(MaatApi::MaatApplicationSearcher).to receive(:call)
        .and_raise(Faraday::ConnectionFailed, "connection refused")
      process_cases
    end

    it "stores the error on the case" do
      expect(xhibit_case.reload.process_errors).to eq(
        "error" => "Faraday::ConnectionFailed", "message" => "connection refused",
      )
    end
  end

  def create_case(first_name:, last_name:)
    XhibitMigratedCase.create!(
      case_urn: "20GD021701",
      xhibit_case_number: "T202540001",
      court_name: "Derby Justice Centre",
      ou_code: "B30PI00",
      case_type: "T",
      defendant_id: "defendant-1",
      defendant_first_name: first_name,
      defendant_last_name: last_name,
      sent_date: Date.new(2019, 10, 25),
    )
  end
end
