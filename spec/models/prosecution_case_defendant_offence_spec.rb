# frozen_string_literal: true

RSpec.describe ProsecutionCaseDefendantOffence, type: :model do
  let(:prosecution_case_id) { SecureRandom.uuid }
  let(:defendant_id) { SecureRandom.uuid }
  let(:offence_id) { SecureRandom.uuid }
  let(:maat_reference) { "A00000001" }
  let(:dummy_maat_reference) { true }
  let(:rep_order_status) { "AP" }
  let(:response_status) { 200 }
  let(:response_body) { { response: "response" }.to_json }

  let(:prosecution_case_defendant_offence) do
    described_class.new(
      prosecution_case_id: prosecution_case_id,
      defendant_id: defendant_id,
      offence_id: offence_id,
      rep_order_status: rep_order_status,
      response_status: response_status,
      response_body: response_body,
    )
  end

  it { expect(prosecution_case_defendant_offence.prosecution_case_id).to eq prosecution_case_id }
  it { expect(prosecution_case_defendant_offence.defendant_id).to eq defendant_id }
  it { expect(prosecution_case_defendant_offence.offence_id).to eq offence_id }
  it { expect(prosecution_case_defendant_offence.rep_order_status).to eq rep_order_status }
  it { expect(prosecution_case_defendant_offence.response_status).to eq response_status }
  it { expect(prosecution_case_defendant_offence.response_body).to eq response_body }

  it do
    should belong_to(:prosecution_case).class_name("ProsecutionCase")
  end
end
