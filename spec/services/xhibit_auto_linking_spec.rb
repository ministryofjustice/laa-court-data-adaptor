require "sidekiq/testing"

RSpec.describe "XHIBIT auto-linking", type: :service do
  subject(:process_cases) { ProcessXhibitCases.call }

  let(:case_urn) { "61GD7528225" }
  let(:prosecution_case_id) { "6fc1f2cb-4a93-4116-84db-f87cc86ec3b8" }
  let(:defendant_id) { "cfc4281f-cdea-494d-8179-3173d30736fd" }
  let(:first_offence_id) { "997ba1dd-e1e2-46cb-ad4d-2c570af869cd" }
  let(:second_offence_id) { "9085871a-797b-4ab8-8072-05ca6deeaac9" }
  let(:maat_id) { 6_559_879 }

  let!(:xhibit_case) { create(:xhibit_migrated_case, case_urn:, defendant_id:, case_type: "T") }

  let(:maat_api_cassette) do
    {
      name: "maat_api/search_maat_application_success",
      options: { tag: :maat_api, match_requests_on: %i[method uri] },
    }
  end

  let(:prosecution_case_cassette) do
    { name: "search_prosecution_case/by_prosecution_case_reference_success_v2" }
  end

  let(:laa_reference_cassette) { { name: laa_reference_cassette_name } }

  before do
    # The service processes every pending case, so the cassettes only add up if
    # this is the only one in the table.
    XhibitMigratedCase.where.not(id: xhibit_case.id).delete_all

    allow(Sqs::MessagePublisher).to receive(:call)
  end

  around do |example|
    Sidekiq::Testing.fake! do
      VCR.use_cassettes([maat_api_cassette,
                         prosecution_case_cassette,
                         laa_reference_cassette]) { example.run }
    end
  end

  context "when every offence is linked" do
    let(:laa_reference_cassette_name) { "laa_reference_recorder/xhibit_auto_link_success" }

    it "retrieves the offences associated with the defendant" do
      process_cases

      expect(ProsecutionCaseDefendantOffence.where(defendant_id:).pluck(:offence_id))
        .to contain_exactly(first_offence_id, second_offence_id)
    end

    it "posts an LAA reference to Common Platform for each offence" do
      process_cases

      expect(a_request(:post, %r{/laaReference/cases/#{prosecution_case_id}/defendant/#{defendant_id}/offences/#{first_offence_id}}))
        .to have_been_made.once
      expect(a_request(:post, %r{/laaReference/cases/#{prosecution_case_id}/defendant/#{defendant_id}/offences/#{second_offence_id}}))
        .to have_been_made.once
    end

    it "records the Common Platform response against each offence" do
      process_cases

      expect(ProsecutionCaseDefendantOffence.where(defendant_id:).pluck(:rep_order_status, :response_status))
        .to eq([%w[AP].push(202), %w[AP].push(202)])
    end

    it "creates a link between the MAAT application and the Common Platform case" do
      process_cases

      expect(LaaReference.find_by(defendant_id:)).to have_attributes(
        maat_reference: maat_id.to_s,
        user_name: User::SYSTEM_USERNAME,
        linked: true,
      )
    end

    it "marks the xhibit case as linked" do
      process_cases

      expect(xhibit_case.reload).to be_auto_linked
      expect(xhibit_case).to have_attributes(
        maat_id: maat_id.to_s,
        linked_by: User::SYSTEM_USERNAME,
        linked_at: within(1.minute).of(Time.zone.now),
      )
    end

    it "publishes one MAAT link message with LAA status reinstatement enabled" do
      process_cases

      expect(Sqs::MessagePublisher).to have_received(:call).with(
        message: hash_including(
          maatId: maat_id.to_s,
          canUpdateLaaStatus: true,
        ),
        queue_url: Rails.configuration.x.aws.sqs_url_link,
        log_info: { maat_reference: maat_id.to_s },
      ).once
    end
  end

  context "when one offence fails to link" do
    let(:laa_reference_cassette_name) { "laa_reference_recorder/xhibit_auto_link_offence_failure" }

    it "still attempts the offence Common Platform rejects" do
      process_cases

      expect(a_request(:post, %r{/laaReference/cases/#{prosecution_case_id}/defendant/#{defendant_id}/offences/#{second_offence_id}}))
        .to have_been_made.once
    end

    it "does not mark the xhibit case as linked" do
      process_cases

      expect(xhibit_case.reload).to be_pending
      expect(xhibit_case).to have_attributes(maat_id: nil, linked_at: nil, linked_by: nil)
    end

    it "does not create the link" do
      process_cases

      expect(LaaReference.find_by(defendant_id:)).to be_nil
    end

    it "records the failure on the xhibit case" do
      process_cases

      expect(xhibit_case.reload.process_errors["unexpected"])
        .to include("error" => "CommonPlatform::Api::Errors::FailedDependency")
    end

    it "does not publish a MAAT link message" do
      process_cases

      expect(Sqs::MessagePublisher).not_to have_received(:call)
    end
  end
end
