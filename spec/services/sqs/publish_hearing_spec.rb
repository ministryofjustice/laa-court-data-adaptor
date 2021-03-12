# frozen_string_literal: true

RSpec.describe Sqs::PublishHearing do
  subject(:publish) do
    described_class.call(shared_time: shared_time,
                         jurisdiction_type: jurisdiction_type,
                         case_urn: case_urn,
                         defendant: defendant,
                         court_centre_code: court_centre_code,
                         court_centre_id: court_centre_id,
                         appeal_data: appeal_data,
                         court_application: court_application,
                         function_type: function_type)
  end

  let(:shared_time) { "2018-10-25T14:45:05.602Z" }
  let(:jurisdiction_type) { "CROWN" }
  let(:case_urn) { "12345" }
  let(:court_centre_code) { "B01DU00" }
  let(:court_centre_id) { "dd22b110-7fbc-3036-a076-e4bb40d0a519" }
  let(:appeal_data) { nil }
  let(:function_type) { nil }

  let(:verdict_hash) do
    {
      'offenceId': "7dc1b279-805f-4ba8-97ea-be635f5764a7",
      'verdictDate': "2018-10-25",
      'verdictType': {
        'category': "GUILTY",
        'categoryType': "GUILTY_CONVICTED",
        'cjsVerdictCode': "123",
        'verdictCode': "789",
      },
    }
  end

  let(:person_defendant) do
    {
      'personDetails': {
        "firstName": "Lavon",
        "lastName": "Rempel",
        'dateOfBirth': "1970-01-01",
        'nationalInsuranceNumber': "QQ123456Q",
        'address': {
          'address1': "address1",
          'address2': "address2",
          'address3': "address3",
          'address4': "address4",
          'address5': "address5",
          'postcode': "postcode",
        },
        'contact': {
          'home': "020 0000 0000",
          'work': "020 0000 0001",
          'mobile': "07000 000000",
          'primaryEmail': "test1@example.com",
          'secondaryEmail': "test2@example.com",
        },
      },
      'arrestSummonsNumber': "AA11A12345",
    }
  end

  let(:judicial_results_array) do
    [
      {
        'cjsCode': "123",
        'label': "Fine",
        'qualifier': "LG",
        'resultText': "Fine - Amount of fine: £1500",
        'orderedDate': "2018-11-11",
        "postHearingCustodyStatus": "R",
        'nextHearing': {
          'listedStartDateTime': "2018-11-11T10:30:00Z",
          'courtCentre': {
            'code': "B16BG00",
            'id': "dd22b110-7fbc-3036-a076-e4bb40d0a519",
          },
        },
      },
    ]
  end

  let(:defendant) do
    {
      'id': "c6cf04b5-901d-4a89-a9ab-767eb57306e4",
      'proceedingsConcluded': true,
      'personDefendant': person_defendant,
      'offences': [
        {
          'id': "7dc1b279-805f-4ba8-97ea-be635f5764a7",
          'offenceCode': "CD98072",
          'offenceTitle': "Robbery",
          'orderIndex': 0,
          'wording': "On 21/10/2018 the defendant robbed someone.",
          'startDate': "2018-10-21",
          'modeOfTrial': "Defendant consents to summary trial",
          'allocationDecision': {
            'motReasonCode': 3,
          },
          'verdict': verdict_hash,
          'plea': {
            'offenceId': "dc1b279-805f-4ba8-97ea-be635f5764a7",
            'pleaDate': "2018-11-11",
            'pleaValue': "PARDON",
          },
          'judicialResults': judicial_results_array,
          'laaApplnReference': {
            'applicationReference': "123456789",
            'statusCode': "AP",
            'statusDescription': "Application Pending",
            'statusDate': "2018-10-24",
          },
        },
      ],
      'defenceOrganisation': {
        'laaAccountNumber': "0A935R",
      },
    }
  end

  let(:defendant_cases) do
    [
      {
        'defendantId': "12dg0279-76sd-gsh4-9fsb-be635fs86da1",
      },
    ]
  end

  let(:court_application) do
    {
      'id': "9dc1b279-805f-4ba8-97ea-be635f576007",
      'defendantASN': "12435",
      'type': {
        'id': "hd820279-76sd-4bv8-9fsb-be635fs87sg2",
        'code': "LA12505",
        'type': "Application for transfer of legal aid",
        'categoryCode': "CO",
        'legislation': "Pursuant to Regulation 14 of the Criminal Legal Aid (Determinations by a Court and Choice of Representative) Regulations 2013.",
      },
      'applicationReceivedDate': "2021-02-12",
      'applicationReference': "98sg3v79-e4sd-4bv8-9fsb-be635fs87783",
      'applicant': {
        'id': "12dg0279-76sd-gsh4-9fsb-be635fs86da1",
        'summonsRequired': false,
        'notificationRequired': false,
        'masterDefendant': {
          'personDefendant': person_defendant,
          'defendantCase': defendant_cases,
        },
      },
      'judicialResults': judicial_results_array,
    }
  end

  let(:sqs_payload) do
    {
      maatId: 123_456_789,
      caseUrn: "12345",
      jurisdictionType: "CROWN",
      asn: "AA11A12345",
      cjsAreaCode: "16",
      caseCreationDate: "2018-10-25",
      cjsLocation: "B16BG",
      docLanguage: "EN",
      proceedingsConcluded: true,
      inActive: "Y",
      function_type: "OFFENCE",
      defendant: {
        forename: "Lavon",
        surname: "Rempel",
        dateOfBirth: "1970-01-01",
        addressLine1: "address1",
        addressLine2: "address2",
        addressLine3: "address3",
        addressLine4: "address4",
        addressLine5: "address5",
        postcode: "postcode",
        nino: "QQ123456Q",
        telephoneHome: "020 0000 0000",
        telephoneWork: "020 0000 0001",
        telephoneMobile: "07000 000000",
        email1: "test1@example.com",
        email2: "test2@example.com",
        offences: [offence_payload],
      },
      session: {
        courtLocation: "B16BG",
        dateOfHearing: "2018-11-11",
        postHearingCustody: "R",
        sessionValidateDate: "2018-11-11",
      },
      ccOutComeData: {
        ccooOutcome: "CONVICTED",
        caseEndDate: "2018-10-25",
        appealType: nil,
      },
    }
  end

  let(:offence_payload) do
    {
      offenceId: "7dc1b279-805f-4ba8-97ea-be635f5764a7",
      offenceCode: "CD98072",
      asnSeq: 0,
      offenceShortTitle: "Robbery",
      offenceClassification: "Defendant consents to summary trial",
      offenceDate: "2018-10-21",
      offenceWording: "On 21/10/2018 the defendant robbed someone.",
      modeOfTrial: 3,
      legalAidStatus: "AP",
      legalAidStatusDate: "2018-10-24",
      legalAidReason: "Application Pending",
      plea: {
        offenceId: "dc1b279-805f-4ba8-97ea-be635f5764a7",
        pleaDate: "2018-11-11",
        pleaValue: "PARDON",
      },
      verdict: {
        offenceId: "7dc1b279-805f-4ba8-97ea-be635f5764a7",
        verdictDate: "2018-10-25",
        category: "GUILTY",
        categoryType: "GUILTY_CONVICTED",
        cjsVerdictCode: "123",
        verdictCode: "789",
      },
      results: [{
        resultCode: "123",
        resultShortTitle: "Fine",
        resultText: "Fine - Amount of fine: £1500",
        resultCodeQualifiers: "LG",
        nextHearingDate: "2018-11-11",
        nextHearingLocation: "B16BG",
        laaOfficeAccount: "0A935R",
        legalAidWithdrawalDate: nil,
      }],
    }
  end
  let(:queue_url) { Rails.configuration.x.aws.sqs_url_hearing_resulted }

  before do
    LaaReference.create!(defendant_id: "c6cf04b5-901d-4a89-a9ab-767eb57306e4", user_name: "cpUser", maat_reference: 123_456_789)
  end

  context "when publishing offence data" do
    let(:function_type) { "OFFENCE" }

    it "triggers a publish call with the expected sqs payload" do
      expect(Sqs::MessagePublisher).to receive(:call).with(message: sqs_payload, queue_url: queue_url)
      publish
    end

    context "when there are historical hearings" do
      before do
        defendant[:offences].each { |offence| offence.delete(:laaApplnReference) }
      end

      it "triggers a publish call with the sqs payload" do
        offence_payload[:legalAidStatus] = nil
        offence_payload[:legalAidStatusDate] = nil
        offence_payload[:legalAidReason] = nil

        expect(Sqs::MessagePublisher).to receive(:call).with(message: sqs_payload, queue_url: queue_url)
        publish
      end
    end

    context "when there are crown court outcomes" do
      context "when there is verdict data" do
        it "creates a crown court outcome hash" do
          expect(CrownCourtOutcomeCreator).to receive(:call).once
          publish
        end
      end

      context "when there is appeal data" do
        let(:verdict_hash) { nil }
        let(:appeal_data) { "appeal_data" }

        it "creates a crown court outcome hash" do
          expect(CrownCourtOutcomeCreator).to receive(:call).once
          publish
        end
      end

      context "when there is no verdict or appeal data" do
        let(:verdict_hash) { nil }

        it "does not create a crown court outcome hash" do
          expect(CrownCourtOutcomeCreator).not_to receive(:call)
          publish
        end
      end
    end
  end

  context "when publishing application data" do
    let(:function_type) { "APPLICATION" }
    let(:sqs_payload) do
      {
        maatId: 123_456_789,
        caseUrn: "98sg3v79-e4sd-4bv8-9fsb-be635fs87783",
        jurisdictionType: "CROWN",
        asn: "12435",
        cjsAreaCode: "B01DU00",
        caseCreationDate: "2018-10-25",
        docLanguage: "EN",
        inActive: true,
        function_type: "APPLICATION",
        defendant: {
          forename: "Lavon",
          surname: "Rempel",
          dateOfBirth: "1970-01-01",
          addressLine1: "address1",
          addressLine2: "address2",
          addressLine3: "address3",
          addressLine4: "address4",
          addressLine5: "address5",
          postcode: "postcode",
          nino: "QQ123456Q",
          telephoneHome: "020 0000 0000",
          telephoneWork: "020 0000 0001",
          telephoneMobile: "07000 000000",
          email1: "test1@example.com",
          email2: "test2@example.com",
          offences: {
            offenceId: "hd820279-76sd-4bv8-9fsb-be635fs87sg2",
            offenceCode: "LA12505",
            offenceShortTitle: "Application for transfer of legal aid",
            offenceClassification: "CO",
            offenceDate: "",
            offenceWording: "Pursuant to Regulation 14 of the Criminal Legal Aid (Determinations by a Court and Choice of Representative) Regulations 2013.",
            results: [{
              resultCode: "123",
              resultShortTitle: "Fine",
              resultText: "Fine - Amount of fine: £1500",
              resultCodeQualifiers: "LG",
              nextHearingDate: "2018-11-11",
              nextHearingLocation: "B16BG00",
            }],
          },
        },
        session: {
          courtLocation: "B01DU00",
          dateOfHearing: "2018-11-11",
          sessionValidateDate: "2021-02-12",
        },
      }
    end

    it "creates message using application data" do
      expect(Sqs::MessagePublisher).to receive(:call).with(message: sqs_payload, queue_url: queue_url)
      publish
    end
  end
end
