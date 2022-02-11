RSpec.describe HmctsCommonPlatform::JudicialResult, type: :model do
  let(:judicial_result) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("judicial_result/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:judicial_result)
    end

    it "generates a JSON representation of the data" do
      expect(judicial_result.to_json["id"]).to eql("be225605-fc15-47aa-b74c-efb8629db58e")
      expect(judicial_result.to_json["label"]).to eql("Legal Aid Transfer Granted")
      expect(judicial_result.to_json["is_adjournment_result"]).to be(false)
      expect(judicial_result.to_json["is_available_for_court_extract"]).to be(true)
      expect(judicial_result.to_json["is_convicted_result"]).to be(false)
      expect(judicial_result.to_json["is_financial_result"]).to be(false)
      expect(judicial_result.to_json["qualifier"]).to eql("qualifier")
      expect(judicial_result.to_json["text"]).to eql("Legal Aid Transfer Granted\nGrant of legal aid transferred to (new firm name) Joe Bloggs Solicitors Ltd, London\nAdditional reasons Defendant's choice\nNew firm's LAA account reference 55558888")
      expect(judicial_result.to_json["cjs_code"]).to eql("4600")
      expect(judicial_result.to_json["ordered_date"]).to eql("2021-03-10")
      expect(judicial_result.to_json["post_hearing_custody_status"]).to eql("A")
      expect(judicial_result.to_json["wording"]).to eql("result wording")
      expect(judicial_result.to_json["prompts"]).to be_present
    end

    it { expect(judicial_result.id).to eql("be225605-fc15-47aa-b74c-efb8629db58e") }
    it { expect(judicial_result.label).to eql("Legal Aid Transfer Granted") }
    it { expect(judicial_result.is_adjournment_result).to be(false) }
    it { expect(judicial_result.is_available_for_court_extract).to be(true) }
    it { expect(judicial_result.is_convicted_result).to be(false) }
    it { expect(judicial_result.is_financial_result).to be(false) }
    it { expect(judicial_result.qualifier).to eql("qualifier") }
    it { expect(judicial_result.text).to eql("Legal Aid Transfer Granted\nGrant of legal aid transferred to (new firm name) Joe Bloggs Solicitors Ltd, London\nAdditional reasons Defendant's choice\nNew firm's LAA account reference 55558888") }
    it { expect(judicial_result.cjs_code).to eql("4600") }
    it { expect(judicial_result.ordered_date).to eql("2021-03-10") }
    it { expect(judicial_result.post_hearing_custody_status).to eql("A") }
    it { expect(judicial_result.wording).to eql("result wording") }
    it { expect(judicial_result.prompts).to all(be_an(HmctsCommonPlatform::JudicialResultPrompt)) }
    it { expect(judicial_result.next_hearing_date).to eql("2021-03-09T15:54:09.871Z") }
    it { expect(judicial_result.next_hearing_court_centre_id).to eql("f8254db1-1683-483e-afb3-b87fde5a0a26") }
    it { expect(judicial_result.category).to eql("FINAL") }
  end

  context "with required fields" do
    let(:data) { JSON.parse(file_fixture("judicial_result/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:judicial_result)
    end

    it { expect(judicial_result.id).to be_nil }
    it { expect(judicial_result.next_hearing_date).to be_nil }
    it { expect(judicial_result.next_hearing_court_centre_id).to be_nil }
  end
end
