# frozen_string_literal: true

require "sidekiq/testing"

RSpec.describe MaatLinkCreator do
  subject(:create_maat_link) { described_class.call(laa_reference_id: laa_reference.id) }

  include ActiveSupport::Testing::TimeHelpers

  let(:maat_reference) { 12_345_678 }
  let(:defendant_id) { "8cd0ba7e-df89-45a3-8c61-4008a2186d64" }
  let(:prosecution_case_id) { "7a0c947e-97b4-4c5a-ae6a-26320afc914d" }
  let(:offence_id) { "cacbd4d4-9102-4687-98b4-d529be3d5710" }
  let(:laa_reference) { LaaReference.create!(defendant_id: defendant_id, user_name: "caseWorker", maat_reference: maat_reference) }

  before do
    ProsecutionCase.create!(
      id: prosecution_case_id,
      body: JSON.parse(file_fixture("prosecution_case_search_result.json").read)["cases"][0],
    )
    ProsecutionCaseDefendantOffence.create!(prosecution_case_id: prosecution_case_id,
                                            defendant_id: defendant_id,
                                            offence_id: offence_id)

    allow(Sqs::PublishLaaReference).to receive(:call)
    allow(Api::RecordLaaReference).to receive(:call)
  end

  it "enqueues a PastHearingsFetcherWorker" do
    Sidekiq::Testing.fake! do
      freeze_time do
        Current.set(request_id: "XYZ") do
          expect(PastHearingsFetcherWorker).to receive(:perform_at).with(30.seconds.from_now, "XYZ", prosecution_case_id).and_call_original
          create_maat_link
        end
      end
    end
  end

  it "calls the Api::RecordLaaReference service once" do
    expect(Api::RecordLaaReference).to receive(:call).once.with(hash_including(application_reference: "12345678"))
    create_maat_link
  end

  it "calls the Sqs::PublishLaaReference service once" do
    expect(Sqs::PublishLaaReference).to receive(:call).once.with(defendant_id: defendant_id, prosecution_case_id: prosecution_case_id, maat_reference: "12345678", user_name: "caseWorker")
    create_maat_link
  end

  context "with multiple offences" do
    before do
      ProsecutionCaseDefendantOffence.create!(prosecution_case_id: prosecution_case_id,
                                              defendant_id: defendant_id,
                                              offence_id: SecureRandom.uuid)
    end

    it "calls the Sqs::PublishLaaReference service once" do
      expect(Sqs::PublishLaaReference).to receive(:call).once.with(defendant_id: defendant_id, prosecution_case_id: prosecution_case_id, maat_reference: "12345678", user_name: "caseWorker")
      create_maat_link
    end

    it "calls the Api::RecordLaaReference service multiple times" do
      expect(Api::RecordLaaReference).to receive(:call).twice.with(hash_including(application_reference: "12345678"))
      create_maat_link
    end
  end

  context "with a dummy_maat_reference" do
    let(:laa_reference) { LaaReference.create!(defendant_id: defendant_id, user_name: "caseWorker", maat_reference: "A10000000") }

    it "does not call the Sqs::PublishLaaReference service" do
      expect(Sqs::PublishLaaReference).not_to receive(:call)
      create_maat_link
    end

    it "creates a dummy maat_reference" do
      expect(Api::RecordLaaReference).to receive(:call).with(hash_including(application_reference: "A10000000"))
      create_maat_link
    end
  end
end
