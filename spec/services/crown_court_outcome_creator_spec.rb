# frozen_string_literal: true

RSpec.describe CrownCourtOutcomeCreator do
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
  let(:appeal_data) { nil }

  subject(:create) { described_class.call(defendant: defendant, appeal_data: appeal_data) }

  context "for a trial" do
    context "with all guilty trial verdicts" do
      it "results in a CONVICTED result" do
        expect(create).to eq({ appealType: nil, caseEndDate: "2018-10-25", ccooOutcome: "CONVICTED" })
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
        expect(create).to eq({ appealType: nil, caseEndDate: "2018-10-25", ccooOutcome: "AQUITTED" })
      end
    end

    context "a mix of guity and not guilty trial verdicts" do
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
        expect(create).to eq({ appealType: nil, caseEndDate: "2018-10-25", ccooOutcome: "PART CONVICTED" })
      end
    end
  end

  context "for an appeal" do
    let(:defendant) do
      {
        'offences': [],
      }
    end
    let(:appeal_result) { "Granted" }
    let(:appeal_data) do
      {
        'appeal_type': "ASE",
        'appeal_outcome': {
          'applicationOutcomeDate': "2019-01-01",
          'applicationOutcome': appeal_result,
        },
      }
    end
    context "with a successful result" do
      it "results in a SUCCESSFUL result" do
        expect(create).to eq({ appealType: "ASE", caseEndDate: "2019-01-01", ccooOutcome: "SUCCESSFUL" })
      end
    end

    context "with an unsuccessful result" do
      let(:appeal_result) { "Refused" }

      it "results in an UNSUCCESSFUL result" do
        expect(create).to eq({ appealType: "ASE", caseEndDate: "2019-01-01", ccooOutcome: "UNSUCCESSFUL" })
      end
    end
  end
end
