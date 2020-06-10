# frozen_string_literal: true

RSpec.describe Sqs::PublishHearing do
  let(:shared_time) { '2018-10-25 11:30:00' }
  let(:jurisdiction_type) { 'MAGISTRATES' }
  let(:case_urn) { '12345' }
  let(:cjs_location) { 'B16BG' }
  let(:defendant) do
    {
      'personDefendant': {
        'personDetails': {
          'defendantName': 'FirstName M LastName',
          'dateOfBirth': '1970-01-01',
          'nationalInsuranceNumber': 'QQ123456Q',
          'address': {
            'address1': 'address1',
            'address2': 'address2',
            'address3': 'address3',
            'address4': 'address4',
            'address5': 'address5',
            'postcode': 'postcode'
          },
          'contact': {
            'home': '020 0000 0000',
            'work': '020 0000 0001',
            'mobile': '07000 000000',
            'primaryEmail': 'test1@example.com',
            'secondaryEmail': 'test2@example.com'
          }
        },
        'arrestSummonsNumber': 'AA11A12345'
      },
      'offences': [
        {
          'offenceCode': 'CD98072',
          'offenceTitle': 'Robbery',
          'orderIndex': 0,
          'wording': 'On 21/10/2018 the defendant robbed someone.',
          'startDate': '2018-10-21',
          'modeOfTrial': 'Defendant consents to summary trial',
          'allocationDecision': {
            'motReasonCode': 3
          },
          'verdict': {
            'verdictDate': '2018-10-25',
            'verdictType': {
              'categoryType': 'GUILTY_CONVICTED'
            }
          },
          'judicialResults': [
            {
              'cjsCode': '123',
              'label': 'Fine',
              'qualifier': 'LG',
              'resultText': 'Fine - Amount of fine: £1500',
              'orderedDate': '2018-11-11',
              'nextHearing': {
                'listedStartDateTime': '2018-11-11 10:30',
                'courtCentre': {
                  'ouCode': 'B16BG'
                }
              },
              'judicialResultPrompts': [
                {
                  'label': 'Remand Status',
                  'value': 'R'
                }
              ]
            }
          ],
          'laaApplnReference': {
            'applicationReference': '123456789',
            'statusCode': 'AP',
            'statusDescription': 'Application Pending',
            'statusDate': '2018-10-24'
          }
        }
      ],
      'laaApplnReference': {
        'applicationReference': '123456789',
        'statusCode': 'AP',
        'statusDescription': 'Application Pending',
        'statusDate': '2018-10-24'
      },
      'defenceOrganisation': {
        'laaAccountNumber': '0A935R'
      }
    }
  end

  let(:sqs_payload) do
    {
      maatId: 123_456_789,
      caseUrn: '12345',
      jurisdictionType: 'MAGISTRATES',
      asn: 'AA11A12345',
      cjsAreaCode: '16',
      caseCreationDate: '2018-10-25',
      cjsLocation: 'B16BG',
      docLanguage: 'EN',
      inActive: 'N',
      defendant: {
        forename: 'FirstName',
        surname: 'LastName',
        dateOfBirth: '1970-01-01',
        addressLine1: 'address1',
        addressLine2: 'address2',
        addressLine3: 'address3',
        addressLine4: 'address4',
        addressLine5: 'address5',
        postcode: 'postcode',
        nino: 'QQ123456Q',
        telephoneHome: '020 0000 0000',
        telephoneWork: '020 0000 0001',
        telephoneMobile: '07000 000000',
        email1: 'test1@example.com',
        email2: 'test2@example.com',
        offences: [
          {
            offenceCode: 'CD98072',
            asnSeq: 0,
            offenceShortTitle: 'Robbery',
            offenceClassification: 'Defendant consents to summary trial',
            offenceDate: '2018-10-21',
            offenceWording: 'On 21/10/2018 the defendant robbed someone.',
            modeOfTrial: 3,
            legalAidStatus: 'AP',
            legalAidStatusDate: '2018-10-24',
            legalAidReason: 'Application Pending',
            results: [{
              resultCode: '123',
              resultShortTitle: 'Fine',
              resultText: 'Fine - Amount of fine: £1500',
              resultCodeQualifiers: 'LG',
              nextHearingDate: '2018-11-11 10:30',
              nextHearingLocation: 'B16BG',
              laaOfficeAccount: '0A935R',
              legalAidWithdrawalDate: nil
            }]
          }
        ]
      },
      session: {
        courtLocation: 'B16BG',
        dateOfHearing: '2018-11-11',
        postHearingCustody: 'R',
        sessionValidateDate: '2018-11-11'
      },
      ccOutComeData: {
        ccooOutcome: 'CONVICTED',
        caseEndDate: '2018-10-25',
        appealType: nil
      }
    }
  end

  subject { described_class.call(shared_time: shared_time, jurisdiction_type: jurisdiction_type, case_urn: case_urn, defendant: defendant, cjs_location: cjs_location) }

  let(:queue_url) { Rails.configuration.x.aws.sqs_url_hearing_resulted }

  it 'triggers a publish call with the sqs payload' do
    expect(Sqs::MessagePublisher).to receive(:call).with(message: sqs_payload, queue_url: queue_url).and_call_original
    subject
  end
end
