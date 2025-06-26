require "rails_helper"

RSpec.describe HearingRepullBatchCreator do
  subject(:call_service) { described_class.call(string) }

  let(:string) { "#{first_maat_id}, #{second_maat_id},\n#{third_maat_id}" }
  let(:first_maat_id) { first_reference.maat_reference }
  let(:second_maat_id) { second_reference.maat_reference }
  let(:third_maat_id) { third_reference.maat_reference }

  let(:first_case) { ProsecutionCase.create!(body: "foo") }
  let(:second_case) { ProsecutionCase.create!(body: "foo") }

  let(:first_defendant_offence) do
    ProsecutionCaseDefendantOffence.create!(prosecution_case: first_case, defendant_id: SecureRandom.uuid, offence_id: SecureRandom.uuid)
  end
  let(:second_defendant_offence) do
    ProsecutionCaseDefendantOffence.create!(prosecution_case: first_case, defendant_id: SecureRandom.uuid, offence_id: SecureRandom.uuid)
  end
  let(:third_defendant_offence) do
    ProsecutionCaseDefendantOffence.create!(prosecution_case: second_case, defendant_id: SecureRandom.uuid, offence_id: SecureRandom.uuid)
  end

  let(:first_reference) do
    LaaReference.create!(maat_reference: "1111111", linked: true, defendant_id: first_defendant_offence.defendant_id, user_name: "123")
  end
  let(:second_reference) do
    LaaReference.create!(maat_reference: "2222222", linked: true, defendant_id: second_defendant_offence.defendant_id, user_name: "123")
  end
  let(:third_reference) do
    LaaReference.create!(maat_reference: "3333333", linked: true, defendant_id: third_defendant_offence.defendant_id, user_name: "123")
  end

  before do
    allow(ProsecutionCaseHearingRepullWorker).to receive(:perform_async)
    call_service
  end

  it "creates a batch" do
    expect(HearingRepullBatch.count).to eq 1
  end

  it "creates two repulls" do
    expect(ProsecutionCaseHearingRepull.count).to eq 2
  end

  it "calls the async jobs" do
    expect(ProsecutionCaseHearingRepullWorker).to have_received(:perform_async).exactly(2).times
  end
end
