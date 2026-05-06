# frozen_string_literal: true

RSpec.describe CourtApplication, type: :model do
  subject(:court_application) { described_class.new(body: { applicationType: application_type }) }

  context "when category is appeal" do
    let(:application_type) { "MC80801" }

    it { expect(court_application.appeal?).to be(true) }
  end

  context "when category is breach" do
    let(:application_type) { "CJ03510" }

    it { expect(court_application.appeal?).to be(false) }
  end

  describe "#supported_category?" do
    context "when the code maps to a known category" do
      let(:application_type) { "MC80801" }

      it { expect(court_application.supported_category?).to be(true) }
    end

    context "when the code produces a nil category" do
      let(:application_type) { "AS14501" }

      it { expect(court_application.supported_category?).to be(false) }
    end
  end
end
