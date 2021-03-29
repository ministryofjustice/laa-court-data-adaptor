RSpec.describe HmctsCommonPlatform::JudicialResult, type: :model do
  let(:data) { JSON.parse(file_fixture("judicial_result/all_fields.json").read).deep_symbolize_keys }
  let(:judicial_result) { described_class.new(data) }

  it "has a code" do
    expect(judicial_result.code).to eql("4600")
  end

  it "has a label" do
    expect(judicial_result.label).to eql("Legal Aid Transfer Granted")
  end

  it "has text" do
    expect(judicial_result.text).to eql("Legal Aid Transfer Granted\nGrant of legal aid transferred to (new firm name) Joe Bloggs Solicitors Ltd, London\nAdditional reasons Defendant's choice\nNew firm's LAA account reference 55558888")
  end

  it "has a qualifier" do
    expect(judicial_result.qualifier).to eql("")
  end

  it "has a next hearing date" do
    expect(judicial_result.next_hearing_date).to eql("2020-03-01")
  end

  it "has a next hearing court centre ID" do
    expect(judicial_result.next_hearing_court_centre_id).to eql("f8254db1-1683-483e-afb3-b87fde5a0a26")
  end

  context "when there is no next hearing object" do
    let(:data) do
      JSON.parse(file_fixture("judicial_result/required_fields.json").read).deep_symbolize_keys
    end

    it "has no next hearing date" do
      expect(judicial_result.next_hearing_date).to be_nil
    end

    it "has no next hearing court centre ID" do
      expect(judicial_result.next_hearing_court_centre_id).to be_nil
    end
  end
end
