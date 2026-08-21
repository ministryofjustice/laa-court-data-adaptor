# frozen_string_literal: true

RSpec.describe CourtApplication, type: :model do
  let(:court_application) { described_class.new(body:) }

  describe "has_offences?" do
    subject { court_application.has_offences? }

    context "when offenceSummary contains an offence" do
      let(:body) do
        {
          subjectSummary: {
            offenceSummary: [
              {
                something: "here",
              },
            ],
          },
        }
      end

      it { is_expected.to be_truthy }
    end

    context "when offenceSummary is empty" do
      let(:body) do
        {
          subjectSummary: {
            offenceSummary: [],
          },
        }
      end

      it { is_expected.to be_falsey }
    end

    context "when offenceSummary does not exist" do
      let(:body) do
        {
          subjectSummary: {},
        }
      end

      it { is_expected.to be_falsey }
    end

    context "when subjectSummary does not exist" do
      let(:body) { {} }

      it { is_expected.to be_falsey }
    end
  end
end
