# frozen_string_literal: true

RSpec.describe ProsecutionCaseDefendantOffence, type: :model do
  let(:prosecution_case_id) { SecureRandom.uuid }
  let(:defendant_id) { SecureRandom.uuid }
  let(:offence_id) { SecureRandom.uuid }
  let(:maat_reference) { 'A00000001' }
  let(:dummy_maat_reference) { true }
  let(:response_status) { 200 }
  let(:response_body) { { response: 'response' }.to_json }
  let(:user_id) { 'user-id' }

  let(:prosecution_case_defendant_offence) do
    described_class.new(
      prosecution_case_id: prosecution_case_id,
      defendant_id: defendant_id,
      offence_id: offence_id,
      maat_reference: maat_reference,
      dummy_maat_reference: dummy_maat_reference,
      response_status: response_status,
      response_body: response_body,
      user_id: user_id
    )
  end

  it { expect(prosecution_case_defendant_offence.prosecution_case_id).to eq prosecution_case_id }
  it { expect(prosecution_case_defendant_offence.defendant_id).to eq defendant_id }
  it { expect(prosecution_case_defendant_offence.offence_id).to eq offence_id }
  it { expect(prosecution_case_defendant_offence.maat_reference).to eq maat_reference }
  it { expect(prosecution_case_defendant_offence.dummy_maat_reference).to eq dummy_maat_reference }
  it { expect(prosecution_case_defendant_offence.response_status).to eq response_status }
  it { expect(prosecution_case_defendant_offence.response_body).to eq response_body }
  it { expect(prosecution_case_defendant_offence.user_id).to eq user_id }
end
