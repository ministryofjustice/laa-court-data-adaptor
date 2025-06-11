# frozen_string_literal: true

require "sidekiq/testing"

RSpec.describe UnlinkProsecutionCaseLaaReferenceWorker, type: :worker do
  subject(:work) do
    described_class.perform_async(request_id, defendant_id, user_name, unlink_reason_code, unlink_other_reason_text, maat_reference)
  end

  let(:defendant_id) { "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3" }
  let(:user_name) { "ABC" }
  let(:unlink_reason_code) { 1 }
  let(:unlink_other_reason_text) { "Wrong defendant" }
  let(:request_id) { "XYZ" }
  let(:prosecution_case_id) { "7a0c947e-97b4-4c5a-ae6a-26320afc914d" }
  let(:maat_reference) { "6666666" }
  let(:set_up_linked_prosecution_case) do
    LaaReference.create!(defendant_id:, user_name: "cpUser", maat_reference: 101_010)
    ProsecutionCase.create!(
      id: prosecution_case_id,
      body: JSON.parse(file_fixture("prosecution_case_search_result.json").read)["cases"][0],
    )
    ProsecutionCaseDefendantOffence.create!(prosecution_case_id:,
                                            defendant_id:,
                                            offence_id: "cacbd4d4-9102-4687-98b4-d529be3d5710")
    allow(CommonPlatform::Api::RecordProsecutionCaseLaaReference).to receive(:call)
  end

  it "queues the job" do
    expect {
      work
    }.to change(described_class.jobs, :size).by(1)
  end

  it "creates a LaaReferenceUnlinker and calls it" do
    set_up_linked_prosecution_case
    Sidekiq::Testing.inline! do
      expect(ProsecutionCaseLaaReferenceUnlinker).to receive(:call).with(
        defendant_id:,
        user_name:,
        unlink_reason_code:,
        unlink_other_reason_text:,
        maat_reference:,
      ).and_call_original
      work
    end
  end

  it "sets the request_id on the Current singleton" do
    Sidekiq::Testing.inline! do
      expect(Current).to receive(:set).with(request_id: "XYZ")
      work
    end
  end
end
