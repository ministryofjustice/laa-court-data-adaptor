require "sidekiq/testing"

RSpec.describe ProcessXhibitCases, type: :service do
  subject(:process_cases) { described_class.call }

  let(:case_urn) { "61GD7528225" }
  let(:defendant_id) { "cfc4281f-cdea-494d-8179-3173d30736fd" }
  let(:maat_fixture) { "success" }
  let(:maat_status) { 200 }
  let(:maat_content_type) { "application/json" }

  let!(:xhibit_case) { create(:xhibit_migrated_case, case_urn:, defendant_id:, case_type: "T") }

  before { stub_maat_search(maat_fixture, status: maat_status, content_type: maat_content_type) }

  context "when there is no matching MAAT application" do
    let(:maat_fixture) { "not_found" }
    let(:maat_status) { 404 }

    it "flags the case for manual action" do
      process_cases

      expect(xhibit_case.reload).to be_action_required
      expect(xhibit_case.process_errors).to eq(
        "maat" => { "message" => "MAAT application not found" },
      )
    end
  end

  context "when the MAAT search returns an error" do
    let(:maat_fixture) { "bad_request" }
    let(:maat_status) { 400 }
    let(:maat_content_type) { "application/problem+json" }

    it "records the error and leaves the case pending" do
      process_cases

      expect(xhibit_case.reload).to be_pending
      expect(xhibit_case.process_errors).to match(
        "maat" => { "error" => 400, "message" => /Invalid request content/ },
      )
    end
  end

  context "when the MAAT search fails" do
    before do
      allow(MaatApi::MaatApplicationSearcher).to receive(:call)
        .and_raise(Faraday::ConnectionFailed, "connection refused")
    end

    it "records the error on the case" do
      process_cases

      expect(xhibit_case.reload.process_errors).to eq(
        "unexpected" => { "error" => "Faraday::ConnectionFailed", "message" => "connection refused" },
      )
    end
  end

  context "when the MAAT application is already linked to a Common Platform case" do
    let(:maat_fixture) { "linked_to_cp_case" }

    it "flags the case for manual action without linking it" do
      process_cases

      expect(xhibit_case.reload).to be_action_required
      expect(xhibit_case).to have_attributes(maat_id: nil, linked_at: nil, linked_by: nil)
      expect(xhibit_case.process_errors).to eq(
        "maat" => { "message" => "MAAT ID already linked with other CP case (01AB1234567)" },
      )
    end
  end

  context "when the MAAT link status cannot be determined" do
    let(:maat_fixture) { "linked_result" }

    it "flags the case for manual action without linking it" do
      process_cases

      expect(xhibit_case.reload).to be_action_required
      expect(xhibit_case).to have_attributes(maat_id: nil, linked_at: nil, linked_by: nil)
      expect(xhibit_case.process_errors).to eq(
        "maat" => { "message" => "MAAT link status could not be determined" },
      )
    end
  end

  context "when the case is not pending" do
    let!(:xhibit_case) { create(:xhibit_migrated_case, :auto_linked, case_urn:, defendant_id:) }

    it "does not search MAAT for it" do
      process_cases

      expect(a_request(:post, /search-maat-application/)).not_to have_been_made
    end
  end

  context "when the case is not found on Common Platform" do
    before do
      allow(CommonPlatform::Api::SearchProsecutionCase).to receive(:call).and_return([])
    end

    it "flags the case for manual action without linking it" do
      process_cases

      expect(xhibit_case.reload).to be_action_required
      expect(xhibit_case).to have_attributes(maat_id: nil, linked_at: nil, linked_by: nil)
      expect(xhibit_case.process_errors).to eq(
        "common_platform" => { "message" => "Case not found on Common Platform" },
      )
    end
  end

  context "when linking raises a validation error" do
    let(:prosecution_case) { instance_double(ProsecutionCase, body: {}, prosecution_case_reference: case_urn) }

    before do
      allow(CommonPlatform::Api::SearchProsecutionCase).to receive(:call).and_return([prosecution_case])
      allow(HmctsCommonPlatform::ProsecutionCaseSummary).to receive(:new).and_return(
        instance_double(
          HmctsCommonPlatform::ProsecutionCaseSummary,
          defendant_summary: instance_double(HmctsCommonPlatform::DefendantSummary),
        ),
      )
      allow(LinkXhibitCase).to receive(:call).and_raise(ActiveRecord::RecordInvalid, xhibit_case)
      allow(xhibit_case).to receive(:errors).and_return(
        instance_double(ActiveModel::Errors, full_messages: ["error message 1", "error message 2"]),
      )
    end

    it "records the error on the case" do
      process_cases

      expect(xhibit_case.reload.process_errors).to eq(
        "link" => { "message" => "Validation failed: error message 1, error message 2" },
      )
    end
  end

  context "when linking against Common Platform" do
    let(:laa_reference_fixture) { "xhibit_auto_link_success" }
    let(:maat_id) { 6_559_879 }

    around do |example|
      Sidekiq::Testing.fake! do
        VCR.use_cassettes([
          { name: "search_prosecution_case/by_prosecution_case_reference_success_v2" },
          { name: "laa_reference_recorder/#{laa_reference_fixture}" },
        ]) { example.run }
      end
    end

    context "when every offence is linked" do
      it "marks the xhibit case as linked" do
        process_cases

        expect(xhibit_case.reload).to be_auto_linked
        expect(xhibit_case).to have_attributes(
          maat_id: maat_id.to_s,
          linked_by: User::SYSTEM_USERNAME,
          linked_at: within(1.minute).of(Time.zone.now),
        )
      end
    end

    context "when an offence fails to link" do
      let(:laa_reference_fixture) { "xhibit_auto_link_offence_failure" }

      it "records the failure and leaves the case pending" do
        process_cases

        expect(xhibit_case.reload).to be_pending
        expect(xhibit_case).to have_attributes(maat_id: nil, linked_at: nil, linked_by: nil)
        expect(xhibit_case.process_errors["unexpected"])
          .to include("error" => "CommonPlatform::Api::Errors::FailedDependency")
      end
    end

    context "when the MAAT application is already linked to a LIBRA case" do
      let(:maat_fixture) { "linked_to_libra_case" }
      let(:maat_id) { 6_672_961 }
      let(:published_queues) { [] }

      before do
        allow(Sqs::MessagePublisher).to receive(:call) { |**args| published_queues << args[:queue_url] }
      end

      it "requests the LIBRA unlink before linking the case" do
        process_cases

        expect(published_queues).to eq([
          Rails.configuration.x.aws.sqs_url_unlink,
          Rails.configuration.x.aws.sqs_url_link,
        ])
        expect(xhibit_case.reload).to be_auto_linked
        expect(xhibit_case).to have_attributes(
          maat_id: maat_id.to_s,
          linked_by: User::SYSTEM_USERNAME,
          linked_at: within(1.minute).of(Time.zone.now),
        )
      end
    end
  end
end
