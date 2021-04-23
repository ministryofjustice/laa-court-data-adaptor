RSpec.describe HmctsCommonPlatform::Plea, type: :model do
  let(:plea) { described_class.new(data) }

  context "when plea has al fields" do
    let(:data) { JSON.parse(file_fixture("plea/all_fields.json").read).deep_symbolize_keys }

    it "has an originating hearing id" do
      expect(plea.originating_hearing_id).to eql("pd22b110-4dbc-3036-a076-e4bb40d0a82t")
    end

    it "has a delegated powers" do
      expect(plea.delegated_powers).to be_a(HmctsCommonPlatform::DelegatedPowers)
    end

    it "has an offence id" do
      expect(plea.offence_id).to eql("vc22b110-od2c-yp36-a106-e4fb40d09987")
    end

    it "has an application id" do
      expect(plea.application_id).to eql("jc227810-od2c-ybb6-a106-e4fb40d099h7")
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
