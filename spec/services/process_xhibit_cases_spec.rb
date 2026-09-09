require "rails_helper"

RSpec.describe ProcessXhibitCases do
  subject(:process_cases) { described_class.call }

  context "when there is no matching MAAT application" do
    let!(:xhibit_case) { create_case(first_name: "nonexistent-first-name", last_name: "nonexistent-last-name") }

    before { stub_maat_search("not_found", status: 404) }

    it "sets status to (manual) action_required" do
      process_cases

      expect(xhibit_case.reload).to be_action_required
    end

    it "stores a message on the case" do
      process_cases

      expect(xhibit_case.reload.process_errors).to eq(
        "maat" => { "message" => "MAAT application not found" },
      )
    end
  end

  context "when there is a matching MAAT application" do
    let!(:xhibit_case) { create_case(first_name: "Tango", last_name: "JF-LAA-T") }
    let(:defendant_summary) { instance_double(HmctsCommonPlatform::DefendantSummary) }
    let(:prosecution_case) { instance_double(ProsecutionCase, body: {}, prosecution_case_reference: xhibit_case.case_urn) }

    before do
      stub_maat_search("success")
      allow(CommonPlatform::Api::SearchProsecutionCase).to receive(:call).and_return([prosecution_case])
      allow(HmctsCommonPlatform::ProsecutionCaseSummary).to receive(:new).and_return(
        instance_double(HmctsCommonPlatform::ProsecutionCaseSummary, defendant_summary:),
      )
    end

    context "when the MAAT application has no existing link" do
      before { allow(LinkXhibitCase).to receive(:call) }

      it "calls the `LinkXhibitCase` class" do
        process_cases

        expect(LinkXhibitCase).to have_received(:call).with(
          an_instance_of(MaatApi::SearchResponse),
          xhibit_case,
          defendant_summary,
        )
      end
    end

    context "when the case is not found on Common Platform" do
      before do
        allow(CommonPlatform::Api::SearchProsecutionCase).to receive(:call).and_return([])
        allow(LinkXhibitCase).to receive(:call)
      end

      it "sets status to (manual) action_required" do
        process_cases

        expect(xhibit_case.reload).to be_action_required
      end

      it "stores the error on the case" do
        process_cases

        expect(xhibit_case.reload.process_errors).to eq(
          "common_platform" => { "message" => "Case not found on Common Platform" },
        )
      end
    end

    context "when LinkXhibitCase throws a validation error" do
      before do
        allow(LinkXhibitCase).to receive(:call).and_raise(ActiveRecord::RecordInvalid, xhibit_case)
        allow(xhibit_case).to receive(:errors).and_return(
          instance_double(ActiveModel::Errors, full_messages: ["error message 1", "error message 2"]),
        )
      end

      it "stores the error on the case" do
        process_cases

        expect(xhibit_case.reload.process_errors).to eq(
          "link" => { "message" => "Validation failed: error message 1, error message 2" },
        )
      end
    end

    context "when LinkXhibitCase throws a non-Faraday error" do
      before do
        allow(LinkXhibitCase).to receive(:call)
          .and_raise(CommonPlatform::Api::Errors::FailedDependency, "Unsuccessful response from Common Platform")
      end

      it "stores the error on the case" do
        process_cases

        expect(xhibit_case.reload.process_errors).to eq(
          "unexpected" => {
            "error" => "CommonPlatform::Api::Errors::FailedDependency",
            "message" => "Unsuccessful response from Common Platform",
          },
        )
      end

      it "does not mark the case as linked" do
        process_cases

        expect(xhibit_case.reload).not_to be_auto_linked
      end
    end

    context "when the MAAT application has an existing link" do
      before do
        stub_maat_search("linked_result")
        allow(LinkXhibitCase).to receive(:call)
      end

      it "does not call the `LinkXhibitCase` class" do
        process_cases

        expect(LinkXhibitCase).not_to have_received(:call)
      end

      it "sets status to (manual) action_required" do
        process_cases

        expect(xhibit_case.reload).to be_action_required
      end

      it "stores the error on the case" do
        process_cases

        expect(xhibit_case.reload.process_errors).to eq(
          "maat" => { "message" => "MAAT application is already linked" },
        )
      end
    end

    context "when the MAAT application is already linked to a Common Platform case" do
      before do
        stub_maat_search("linked_to_cp_case")
        allow(LinkXhibitCase).to receive(:call)
      end

      it "does not call the `LinkXhibitCase` class" do
        process_cases

        expect(LinkXhibitCase).not_to have_received(:call)
      end

      it "sets status to (manual) action_required" do
        process_cases

        expect(xhibit_case.reload).to be_action_required
      end

      it "leaves the case unlinked" do
        process_cases

        expect(xhibit_case.reload).to have_attributes(maat_id: nil, linked_at: nil, linked_by: nil)
      end

      it "stores the error on the case" do
        process_cases
        expect(xhibit_case.reload.process_errors).to eq(
          "maat" => { "message" => "MAAT ID already linked with other CP case (01AB1234567)" },
        )
      end
    end
  end

  context "when the search fails" do
    let!(:xhibit_case) { create_case(first_name: "Tango", last_name: "JF-LAA-T") }

    before do
      allow(MaatApi::MaatApplicationSearcher).to receive(:call)
        .and_raise(Faraday::ConnectionFailed, "connection refused")
    end

    it "stores the error on the case" do
      process_cases

      expect(xhibit_case.reload.process_errors).to eq(
        "unexpected" => { "error" => "Faraday::ConnectionFailed", "message" => "connection refused" },
      )
    end
  end

  context "when one case in the batch fails" do
    let!(:failing_case) { create_case(first_name: "Failing", last_name: "Case") }
    let!(:succeeding_case) { create_case(first_name: "Succeeding", last_name: "Case") }

    let(:response) { instance_double(MaatApi::SearchResponse, success?: true, existing_link?: false) }

    before do
      allow(MaatApi::MaatApplicationSearcher).to receive(:call).and_return(response)
      allow(CommonPlatform::Api::SearchProsecutionCase).to receive(:call).and_return(
        [instance_double(ProsecutionCase, body: {}, prosecution_case_reference: failing_case.case_urn)],
      )
      allow(HmctsCommonPlatform::ProsecutionCaseSummary).to receive(:new).and_return(
        instance_double(
          HmctsCommonPlatform::ProsecutionCaseSummary,
          defendant_summary: instance_double(HmctsCommonPlatform::DefendantSummary),
        ),
      )
      allow(LinkXhibitCase).to receive(:call) do |_maat_response, xhibit_case, _defendant_summary|
        raise CommonPlatform::Api::Errors::FailedDependency, "boom" if xhibit_case.id == failing_case.id
      end
    end

    it "still processes the remaining cases" do
      process_cases

      expect(LinkXhibitCase).to have_received(:call).twice
      expect(succeeding_case.reload.process_errors).to be_nil
    end
  end

  context "when the cases are not pending" do
    before do
      create(:xhibit_migrated_case, :auto_linked, defendant_last_name: "AlreadyLinked")
      create(:xhibit_migrated_case, :action_required, defendant_last_name: "NeedsAttention")
    end

    it "does not search MAAT for them" do
      process_cases

      expect(a_request(:post, /search-maat-application/)).not_to have_been_made
    end
  end

  def create_case(first_name:, last_name:)
    create(:xhibit_migrated_case,
           defendant_first_name: first_name,
           defendant_last_name: last_name)
  end
end
