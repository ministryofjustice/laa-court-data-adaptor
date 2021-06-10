# frozen_string_literal: true

RSpec.describe CrownCourtOutcomeCreator do
  subject(:create) { described_class.call(defendant: defendant) }

  let(:guilty_verdict) do
    {
      'verdictDate': "2018-10-25",
      'verdictType': {
        'categoryType': "GUILTY_CONVICTED",
      },
    }
  end
  let(:not_guilty_verdict) do
    {
      'verdictDate': "2018-10-25",
      'verdictType': {
        'categoryType': "NOT_GUILTY",
      },
    }
  end
  let(:defendant) do
    {
      'offences': [
        {
          'verdict': guilty_verdict,
        },
        {
          'verdict': guilty_verdict,
        },
      ],
    }
  end

  describe "a trial" do
    context "with all guilty trial verdicts" do
      it "results in a CONVICTED result" do
        expect(create).to eq({ caseEndDate: "2018-10-25", ccooOutcome: "CONVICTED" })
      end
    end

    context "with all not guilty trial verdicts" do
      let(:defendant) do
        {
          'offences': [
            {
              'verdict': not_guilty_verdict,
            },
            {
              'verdict': not_guilty_verdict,
            },
          ],
        }
      end

      it "results in a AQUITTED result" do
        expect(create).to eq({ caseEndDate: "2018-10-25", ccooOutcome: "AQUITTED" })
      end
    end

    context "with a mix of guity and not guilty trial verdicts" do
      let(:defendant) do
        {
          'offences': [
            {
              'verdict': guilty_verdict,
            },
            {
              'verdict': not_guilty_verdict,
            },
          ],
        }
      end

      it "results in a PART CONVICTED result" do
        expect(create).to eq({ caseEndDate: "2018-10-25", ccooOutcome: "PART CONVICTED" })
      end
    end
  end
end
