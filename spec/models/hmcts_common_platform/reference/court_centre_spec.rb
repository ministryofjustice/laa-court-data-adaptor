RSpec.describe HmctsCommonPlatform::Reference::CourtCentre, type: :model do
  describe ".find" do
    context "when the ID is recognised" do
      subject(:court_centre) { described_class.find("14876ea1-5f7c-32ef-9fbd-aa0b63193550") }

      it { is_expected.to be_a(described_class) }
      it { expect(court_centre.oucode).to eq("B30PI00") }
    end

    context "when the ID is not recognised" do
      subject { described_class.find(SecureRandom.uuid) }

      it { is_expected.to be_nil }
    end
  end
end
