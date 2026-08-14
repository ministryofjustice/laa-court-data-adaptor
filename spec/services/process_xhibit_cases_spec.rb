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

    let!(:xhibit_case) { create_case(first_name: "Tango", last_name: "JF-LAA-T") }

    context "when the maat application has no existing link" do
      let(:cassette) { "maat_api/search_maat_application_success" }

      before do
        allow(LinkXhibitCase).to receive(:call)
        process_cases
      end

      it "calls the `LinkXhibitCase` class" do
        expect(LinkXhibitCase).to have_received(:call).with(
          an_instance_of(MaatApi::SearchResponse),
          xhibit_case,
        )
      end
    end

    context "when LinkXhibitCase throws a validation error" do
      let(:cassette) { "maat_api/search_maat_application_success" }

      before do
        allow(LinkXhibitCase).to receive(:call).and_raise(ActiveRecord::RecordInvalid, xhibit_case)
        allow(xhibit_case).to receive(:errors).and_return(
          instance_double(ActiveModel::Errors, full_messages: ["error message 1", "error message 2"]),
        )
        process_cases
      end

      it "stores the error on the case" do
        expect(xhibit_case.reload.process_errors).to eq(
          "message" => "Validation failed: error message 1, error message 2",
        )
      end
    end

    context "when the maat application has an existing link" do
      let(:cassette) { "maat_api/search_maat_application_success_linked_result" }

      before do
        allow(LinkXhibitCase).to receive(:call)
        process_cases
      end

      it "does not call the `LinkXhibitCase` class" do
        expect(LinkXhibitCase).not_to have_received(:call)
      end
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
    create(:xhibit_migrated_case,
           defendant_first_name: first_name,
           defendant_last_name: last_name)
  end
end
