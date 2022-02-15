RSpec.describe HmctsCommonPlatform::JudicialResultPrompt, type: :model do
  let(:judicial_result_prompt) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("judicial_result_prompt.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:judicial_result_prompt)
    end

    it "generates a JSON representation of the data" do
      expect(judicial_result_prompt.to_json["type_id"]).to eql("1745ee94-1564-48b3-9eca-4a34e1baf706")
      expect(judicial_result_prompt.to_json["is_available_for_court_extract"]).to be true
      expect(judicial_result_prompt.to_json["welsh_label"]).to eql("Welsh label")
      expect(judicial_result_prompt.to_json["value"]).to eql("Joe Bloggs Solicitors Ltd, London")
      expect(judicial_result_prompt.to_json["welsh_value"]).to eql("Joe Bloggs Solicitors Ltd, Cardiff")
      expect(judicial_result_prompt.to_json["qualifier"]).to eql("qualifier")
      expect(judicial_result_prompt.to_json["prompt_sequence"]).to be(100)
      expect(judicial_result_prompt.to_json["prompt_reference"]).to eql("grantOfLegalAidTransferredToNewFirmName")
      expect(judicial_result_prompt.to_json["is_financial_imposition"]).to be false
      expect(judicial_result_prompt.to_json["user_groups"]).to eql([])
    end

    it { expect(judicial_result_prompt.type_id).to eql("1745ee94-1564-48b3-9eca-4a34e1baf706") }
    it { expect(judicial_result_prompt.is_available_for_court_extract).to be true }
    it { expect(judicial_result_prompt.welsh_label).to eql("Welsh label") }
    it { expect(judicial_result_prompt.value).to eql("Joe Bloggs Solicitors Ltd, London") }
    it { expect(judicial_result_prompt.welsh_value).to eql("Joe Bloggs Solicitors Ltd, Cardiff") }
    it { expect(judicial_result_prompt.qualifier).to eql("qualifier") }
    it { expect(judicial_result_prompt.prompt_sequence).to be(100) }
    it { expect(judicial_result_prompt.prompt_reference).to eql("grantOfLegalAidTransferredToNewFirmName") }
    it { expect(judicial_result_prompt.is_financial_imposition).to be false }
    it { expect(judicial_result_prompt.user_groups).to eql([]) }
  end
end
