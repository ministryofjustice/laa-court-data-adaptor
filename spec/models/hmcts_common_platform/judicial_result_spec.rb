RSpec.describe HmctsCommonPlatform::JudicialResult, type: :model do
  let(:judicial_result) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("judicial_result/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:judicial_result)
    end

    it "has an id" do
      expect(judicial_result.id).to eql("be225605-fc15-47aa-b74c-efb8629db58e")
    end

    it "has a CJS code" do
      expect(judicial_result.cjs_code).to eql("4600")
    end

    it "has a label" do
      expect(judicial_result.label).to eql("Legal Aid Transfer Granted")
    end

    it "has text" do
      expect(judicial_result.text).to eql("Legal Aid Transfer Granted\nGrant of legal aid transferred to (new firm name) Joe Bloggs Solicitors Ltd, London\nAdditional reasons Defendant's choice\nNew firm's LAA account reference 55558888")
    end

    it "has a qualifier" do
      expect(judicial_result.qualifier).to eql("qualifier")
    end

    it "has a next hearing datetime" do
      expect(judicial_result.next_hearing_date).to eql("2021-03-09T15:54:09.871Z")
    end

    it "has a next hearing court centre ID" do
      expect(judicial_result.next_hearing_court_centre_id).to eql("f8254db1-1683-483e-afb3-b87fde5a0a26")
    end

    it "has is_financial_result" do
      expect(judicial_result.is_financial_result).to be(false)
    end

    it "has is_available_for_court_extract" do
      expect(judicial_result.is_available_for_court_extract).to be(true)
    end

    it "has is_convicted_result" do
      expect(judicial_result.is_convicted_result).to be(false)
    end

    it "has is_adjournment_result" do
      expect(judicial_result.is_adjournment_result).to be(false)
    end
  end

  context "with required fields" do
    let(:data) { JSON.parse(file_fixture("judicial_result/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:judicial_result)
    end

    it "has no id" do
      expect(judicial_result.id).to be_nil
    end

    it "has no next hearing date" do
      expect(judicial_result.next_hearing_date).to be_nil
    end

    it "has no next hearing court centre ID" do
      expect(judicial_result.next_hearing_court_centre_id).to be_nil
    end
  end
end
