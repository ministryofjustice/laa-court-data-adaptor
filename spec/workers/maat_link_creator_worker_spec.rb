# frozen_string_literal: true

require "sidekiq/testing"

RSpec.describe MaatLinkCreatorWorker, type: :worker do
  subject(:work) do
    described_class.perform_async(request_id, laa_reference.id)
  end

  let(:request_id) { "XYZ" }
  let(:maat_reference) { 12_345_678 }
  let(:defendant_id) { "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3" }
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

    allow(Api::RecordLaaReference).to receive(:call)
    allow(Api::GetHearingResults).to receive(:call)
  end

  it "queues the job" do
    expect {
      work
    }.to change(described_class.jobs, :size).by(1)
  end

  it "creates a MaatLinkCreator and calls it" do
    Sidekiq::Testing.inline! do
      expect(MaatLinkCreator).to receive(:call).once.with(laa_reference_id: laa_reference.id).and_call_original
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
