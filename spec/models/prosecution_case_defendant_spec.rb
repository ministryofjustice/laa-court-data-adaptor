# frozen_string_literal: true

RSpec.describe ProsecutionCaseDefendantOffence, type: :model do
  let(:prosecution_case_id) { SecureRandom.uuid }
  let(:defendant_id) { SecureRandom.uuid }
  let(:offence_id) { SecureRandom.uuid }
  let(:prosecution_case_defendant_offence) do
    described_class.new(
      prosecution_case_id: prosecution_case_id,
      defendant_id: defendant_id,
      offence_id: offence_id
    )
  end

  it { expect(prosecution_case_defendant_offence.prosecution_case_id).to eq prosecution_case_id }
  it { expect(prosecution_case_defendant_offence.defendant_id).to eq defendant_id }
  it { expect(prosecution_case_defendant_offence.offence_id).to eq offence_id }
end
