RSpec.describe HmctsCommonPlatform::Verdict, type: :model do
  let(:verdict) { described_class.new(data) }

  context "when verdict has all fields" do
    let(:data) { JSON.parse(file_fixture("verdict/all_fields.json").read).deep_symbolize_keys }

    it "has an offence id" do
      expect(verdict.offence_id).to eql("3f153786-f3cf-4311-bc0c-2d6f48af68a1")
    end

    it "has a date" do
      expect(verdict.verdict_date).to eql("2021-04-10")
    end

    it "has a verdict type category" do
      expect(verdict.verdict_type_category).to eql("A")
    end

    it "has a verdict type category type" do
      expect(verdict.verdict_type_category_type).to eql("Type A")
    end

    it "has a verdict type cjs verdict code" do
      expect(verdict.verdict_type_cjs_verdict_code).to eql("1093")
    end

    it "has a verdict type verdict code" do
      expect(verdict.verdict_type_verdict_code).to eql("367A")
    end

    context "when verdict has only required fields with offence id option" do
      let(:data) do
        JSON.parse(file_fixture("verdict/required_fields_with_offence_id.json").read).deep_symbolize_keys
      end

      it "has an offence id" do
        expect(verdict.offence_id).to eql("3f153786-f3cf-4311-bc0c-2d6f48af68a1")
      end

      it "has a verdict date" do
        expect(verdict.verdict_date).to eql("2021-04-10")
      end

      it "has a verdict type category" do
        expect(verdict.verdict_type_category).to eql("A")
      end

      it "has a verdict type category type" do
        expect(verdict.verdict_type_category_type).to eql("Type A")
      end

      it "has no verdict type cjs verdict code" do
        expect(verdict.verdict_type_cjs_verdict_code).to be_nil
      end

      it "has no verdict type verdict code" do
        expect(verdict.verdict_type_verdict_code).to be_nil
      end
    end
  end

  context "when verdict has only required fields with application id option" do
    let(:data) do
      JSON.parse(file_fixture("verdict/required_fields_with_application_id.json").read).deep_symbolize_keys
    end

    it "has no offence id" do
      expect(verdict.offence_id).to be_nil
    end

    it "has a verdict date" do
      expect(verdict.verdict_date).to eql("2021-04-10")
    end

    it "has a verdict type category" do
      expect(verdict.verdict_type_category).to eql("A")
    end

    it "has a verdict type category type" do
      expect(verdict.verdict_type_category_type).to eql("Type A")
    end

    it "has a verdict type cjs verdict code" do
      expect(verdict.verdict_type_cjs_verdict_code).to be_nil
    end

    it "has a verdict type verdict code" do
      expect(verdict.verdict_type_verdict_code).to be_nil
    end
  end
end
