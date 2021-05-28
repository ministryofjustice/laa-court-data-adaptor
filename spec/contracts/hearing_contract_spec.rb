RSpec.describe HearingContract do
  describe "hearing" do
    it "requires an ID" do
      result = described_class.new.call({ hearing: {} })
      hearing_errors = result.errors.to_h[:hearing]

      expect(hearing_errors[:id]).to eq(["is missing"])
    end

    it "requires a jurisdictionType" do
      result = described_class.new.call({ hearing: {} })
      hearing_errors = result.errors.to_h[:hearing]

      expect(hearing_errors[:jurisdictionType]).to eq(["is missing"])
    end

    it "requires a courtCentre" do
      result = described_class.new.call({ hearing: {} })
      hearing_errors = result.errors.to_h[:hearing]

      expect(hearing_errors[:courtCentre]).to eq(["is missing"])
    end

    it "requires a type" do
      result = described_class.new.call({ hearing: {} })
      hearing_errors = result.errors.to_h[:hearing]

      expect(hearing_errors[:type]).to eq(["is missing"])
    end
  end

  describe "hearing court centre" do
    it "requires an ID" do
      result = described_class.new.call({ hearing: { courtCentre: {} } })
      court_centre_errors = result.errors.to_h[:hearing][:courtCentre]

      expect(court_centre_errors[:id]).to eq(["is missing"])
    end
  end

  describe "hearing type" do
    it "requires an ID" do
      result = described_class.new.call({ hearing: { type: {} } })
      court_centre_errors = result.errors.to_h[:hearing][:type]

      expect(court_centre_errors[:id]).to eq(["is missing"])
    end

    it "requires a description" do
      result = described_class.new.call({ hearing: { type: {} } })
      court_centre_errors = result.errors.to_h[:hearing][:type]

      expect(court_centre_errors[:description]).to eq(["is missing"])
    end
  end
end
