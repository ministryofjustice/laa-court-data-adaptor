RSpec.describe HmctsCommonPlatform::LesserOrAlternativeOffence, type: :model do
  let(:lesser_or_alternative_offence) { described_class.new(data) }

  context "when lesser or alternative offence has all fields" do
    let(:data) { JSON.parse(file_fixture("lesser_or_alternative_offence/all_fields.json").read).deep_symbolize_keys }

    it "has an offence definition id" do
      expect(lesser_or_alternative_offence.offence_definition_id).to eql("pd22b110-4dbc-3036-a076-e4bb40d0a82t")
    end

    it "has an offence code" do
      expect(lesser_or_alternative_offence.offence_code).to eql("AAA")
    end

    it "has an offence title" do
      expect(lesser_or_alternative_offence.offence_title).to eql("Drunkenness in a public place")
    end

    it "has an offence title Welsh" do
      expect(lesser_or_alternative_offence.offence_title_welsh).to eql("Meddwdod mewn man cyhoeddus")
    end

    it "has an offence legislation" do
      expect(lesser_or_alternative_offence.offence_legislation).to eql("Criminal Justice Act 1967")
    end

    it "has an offence legislation Welsh" do
      expect(lesser_or_alternative_offence.offence_legislation_welsh).to eql("Deddf Cyfiawnder Troseddol 1967")
    end
  end

  context "when lesser or alternative offence has only required fields" do
    let(:data) do
      JSON.parse(file_fixture("lesser_or_alternative_offence/required_fields.json").read).deep_symbolize_keys
    end

    it "has no offence title Welsh" do
      expect(lesser_or_alternative_offence.offence_title_welsh).to be_nil
    end

    it "has no offence legislation Welsh" do
      expect(lesser_or_alternative_offence.offence_legislation_welsh).to be_nil
    end
  end
end
