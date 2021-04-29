require "rails_helper"

RSpec.describe Feature, type: :model do
  describe ".enabled?" do
    after do
      FeatureFlag.delete_all
    end

    it "returns false if there are no features by the specified name" do
      expect(described_class.enabled?("example")).to eq(false)
    end

    it "returns true when the feature flag is enabled in the database" do
      FeatureFlag.create!(name: "multiday_hearings", enabled: true)
      expect(described_class.enabled?("multiday_hearings")).to eq(true)
    end

    it "returns false when the feature flag is disabled in the database" do
      FeatureFlag.create!(name: "multiday_hearings", enabled: false)
      expect(described_class.enabled?("multiday_hearings")).to eq(false)
    end
  end
end
