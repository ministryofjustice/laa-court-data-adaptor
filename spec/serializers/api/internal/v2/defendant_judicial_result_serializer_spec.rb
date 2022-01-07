RSpec.describe Api::Internal::V2::DefendantJudicialResultSerializer do
  subject(:attributes_hash) { described_class.new(defendant_judicial_result).serializable_hash[:data][:attributes] }

  let(:defendant_judicial_result_data) { JSON.parse(file_fixture("defendant_judicial_result/all_fields.json").read) }
  let(:defendant_judicial_result) { HmctsCommonPlatform::DefendantJudicialResult.new(defendant_judicial_result_data) }

  it { expect(attributes_hash[:id]).to eql("be225605-fc15-47aa-b74c-efb8629db58e") }
  it { expect(attributes_hash[:defendant_id]).to eql("b9d35f79-875d-4205-8a20-254a6e2877d9") }
  it { expect(attributes_hash[:cjs_code]).to eql("4600") }
  it { expect(attributes_hash[:ordered_date]).to eql("2021-03-10") }
  it { expect(attributes_hash[:text]).to eql("Legal Aid Transfer Granted\nGrant of legal aid transferred to (new firm name) Joe Bloggs Solicitors Ltd, London\nAdditional reasons Defendant's choice\nNew firm's LAA account reference 55558888") }
end
