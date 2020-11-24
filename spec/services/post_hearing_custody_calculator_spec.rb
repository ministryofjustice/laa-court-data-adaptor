# frozen_string_literal: true

RSpec.describe PostHearingCustodyCalculator do
  let(:offences) do
    [{
      'id': "7dc1b279-805f-4ba8-97ea-be635f5764a7",
      'offenceCode': "CD98072",
      'offenceTitle': "Robbery",
      'orderIndex': 0,
      'judicialResults': judicial_results,
    }]
  end

  let(:judicial_results) do
    [{
      'cjsCode': "123",
      'label': "Fine",
      'qualifier': "LG",
      'resultText': "Fine - Amount of fine: £1500",
      'orderedDate': "2018-11-11",
      "postHearingCustodyStatus": "A",
      'nextHearing': {
        'listedStartDateTime': "2018-11-11T10:30:00Z",
        'courtCentre': {
          'id': "dd22b110-7fbc-3036-a076-e4bb40d0a519",
        },
      },
    }]
  end

  subject { described_class.call(offences: offences) }

  it { is_expected.to eq("A") }

  context "with multiple judicial results" do
    let(:judicial_results) do
      [
        {
          'cjsCode': "123",
          "postHearingCustodyStatus": "A",
        },
        {
          "cjsCode": "4506",
          "postHearingCustodyStatus": "R",
        },
      ]
    end

    it { is_expected.to eq("R") }
  end

  context "with multiple offences" do
    let(:offences) do
      [{
        "id": "34ded235-8631-4be3-a661-82cc4be14822",
        "offenceCode": "AG28002",
        "judicialResults": [
          {
            'cjsCode': "123",
            "postHearingCustodyStatus": "A",
          },
          {
            "cjsCode": "4506",
            "postHearingCustodyStatus": "C",
          },
        ],
      },
       {
         "id": "34063c1e-d0cf-4d02-afe8-d0d8123b2b38",
         "offenceCode": "AG28001",
         "judicialResults": [
           {
             "cjsCode": "4506",
             "postHearingCustodyStatus": "C",
           },
         ],
       }]
    end

    it { is_expected.to eq("C") }
  end

  context "when missing some post hearing custody statuses" do
    let(:offences) do
      [{
        "id": "34ded235-8631-4be3-a661-82cc4be14822",
        "offenceCode": "AG28002",
        "judicialResults": [
          {
            'cjsCode': "123",
          },
          {
            "cjsCode": "4506",
            "postHearingCustodyStatus": "C",
          },
        ],
      }]
    end

    it { is_expected.to eq("C") }
  end

  context "when missing all post hearing custody statuses" do
    let(:offences) do
      [{
        "id": "34ded235-8631-4be3-a661-82cc4be14822",
        "offenceCode": "AG28002",
        "judicialResults": [
          {
            'cjsCode': "123",
          },
          {
            "cjsCode": "4506",
          },
        ],
      }]
    end

    it { is_expected.to eq("A") }
  end
end
