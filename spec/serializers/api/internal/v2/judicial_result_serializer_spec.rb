RSpec.describe Api::Internal::V2::JudicialResultSerializer do
  subject(:attributes_hash) { described_class.new(judicial_result).serializable_hash[:data][:attributes] }

  let(:judicial_result_data) { JSON.parse(file_fixture("judicial_result/all_fields.json").read) }
  let(:judicial_result) { HmctsCommonPlatform::JudicialResult.new(judicial_result_data) }

  it { expect(attributes_hash[:id]).to eql("be225605-fc15-47aa-b74c-efb8629db58e") }
  it { expect(attributes_hash[:cjs_code]).to eql("4600") }
  it { expect(attributes_hash[:text]).to eql("Legal Aid Transfer Granted\nGrant of legal aid transferred to (new firm name) Joe Bloggs Solicitors Ltd, London\nAdditional reasons Defendant's choice\nNew firm's LAA account reference 55558888") }
end
