RSpec.describe ProsecutionConclusionContract do
  let(:prosecution_conclusion) do
    {
      "prosecutionConcluded": {
        "prosecutionCaseId": "dc7d0f3e-6316-4d5e-8827-3e6a3ddfdebb",
        "defendantId": "67d948d1-1792-4565-a522-8ab2425827e8",
        "isConcluded": true,
        "hearingIdWhereChangeOccured": "96095df2-b66b-421d-881e-c45fd267e751",
        "concludedOffenceSummary": [
          {
            "offenceId": "fb2a3ecb-fc1a-4a80-88ac-222478bc4a92",
            "offenceCode": "PT00011",
            "proceedingsConcluded": true,
            "plea": {
              "originatingHearingId": "badf2bc4-3041-4545-a0d1-89795c667c38",
              "value": "Plea value",
              "pleaDate": "11-08-2021",
            },
            "verdict": {
              "verdictDate": "2021-12-01",
              "originatingHearingId": "5ce145fa-2a0d-44a5-a8e3-65af4ce1af55",
              "verdictType": {
                "description": "verdict type description",
                "category": "verdict type category",
                "categoryType": "category type",
                "sequence": 1,
                "verdictTypeId": "fc0b038e-6378-4979-9f39-69ed40249bcb",
              },
            },
          },
        ],
      },
    }
  end

  context "with all fields" do
    it "is valid" do
      expect(described_class.new.call(prosecution_conclusion)).to be_a_success
    end
  end
end
