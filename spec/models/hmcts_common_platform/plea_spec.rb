RSpec.describe HmctsCommonPlatform::Plea, type: :model do
  let(:plea) { described_class.new(data) }

  context "when plea has all fields" do
    let(:data) { JSON.parse(file_fixture("plea/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:plea)
    end

    it "has an originating hearing id" do
      expect(plea.originating_hearing_id).to eql("a6b07866-faa0-48d5-9faf-c18121e49aaf")
    end

    it "has a delegated powers" do
      expect(plea.delegated_powers).to be_a(HmctsCommonPlatform::DelegatedPowers)
    end

    it "has an offence id" do
      expect(plea.offence_id).to eql("5f541240-8807-4d45-a085-97693a50b15d")
    end

    it "has an application id" do
      expect(plea.application_id).to eql("cd6d6cb3-26ad-4df1-b1e1-1bd1a07cb292")
    end

    it "has a plea date" do
      expect(plea.plea_date).to eql("2021-03-01")
    end

    it "has a plea value" do
      expect(plea.plea_value).to eql("GUILTY")
    end

    it "has a lesser or alternative offence" do
      expect(plea.lesser_or_alternative_offence).to be_a(HmctsCommonPlatform::LesserOrAlternativeOffence)
    end
  end

  context "when plea has only required fields with offence id option" do
    let(:data) do
      JSON.parse(file_fixture("plea/required_fields_with_offence_id.json").read).deep_symbolize_keys
    end

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:plea)
    end

    it "has no originating hearing id" do
      expect(plea.originating_hearing_id).to be_nil
    end

    it "has a blank delegated powers object" do
      expect(plea.delegated_powers).to be_blank
    end

    it "has no application id" do
      expect(plea.application_id).to be_nil
    end

    it "has a blank lesser or alternative offence object" do
      expect(plea.lesser_or_alternative_offence).to be_blank
    end
  end

  context "when there are only required fields with application id option" do
    let(:data) do
      JSON.parse(file_fixture("plea/required_fields_with_application_id.json").read).deep_symbolize_keys
    end

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:plea)
    end

    it "has no originating hearing id" do
      expect(plea.originating_hearing_id).to be_nil
    end

    it "has a blank delegated powers object" do
      expect(plea.delegated_powers).to be_blank
    end

    it "has no offence id" do
      expect(plea.offence_id).to be_nil
    end

    it "has a blank lesser or alternative offence object" do
      expect(plea.lesser_or_alternative_offence).to be_blank
    end
  end
end
