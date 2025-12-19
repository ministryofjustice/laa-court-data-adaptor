# frozen_string_literal: true

RSpec.describe SupportedCourtApplicationTypes do
  describe ".get_category_by_code" do
    it "returns the category for a supported code" do
      expect(described_class.get_category_by_code("CJ08521")).to eq("breach")
    end

    it "returns nil when the code does not exist" do
      expect(described_class.get_category_by_code("MISSING_CODE")).to be_nil
    end
  end
end
