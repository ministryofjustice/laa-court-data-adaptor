RSpec.describe CourtCentreCodeLookup, type: :service do
  describe ".find" do
    context "when the ID is recognised" do
      it "returns the oucode" do
        expect(described_class.find("14876ea1-5f7c-32ef-9fbd-aa0b63193550")).to eq("B30PI00")
      end
    end

    context "when the ID is not recognised" do
      it { expect(described_class.find(SecureRandom.uuid)).to be_nil }
    end
  end
end
