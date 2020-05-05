# frozen_string_literal: true

RSpec.describe Sqs::PublishMagistratesHearing do
  let(:shared_time) { '2018-10-25 11:30:00' }
  let(:jurisdiction_type) { 'MAGISTRATES' }
  let(:case_status) { 'OPEN' }
  let(:case_urn) { '12345' }
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
          'wording': 'On 21/10/2018 the defendant robbed someone.',
          'startDate': '2018-10-21',
          'allocationDecision': {
            'motReasonCode': 3
          },
          'judicialResults': [
            {
              'cjsCode': '123',
              'label': 'Fine',
              'qualifier': 'LG',
              'resultText': 'Fine - Amount of fine: £1500',
              'orderedDate': '2018-11-11',
              'nextHearing': {
                'listedStartDateTime': '2018-11-11 10:30'
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
            'applicationReference': 'appln001',
            'statusCode': 'AP',
            'statusDescription': 'Application Pending',
            'statusDate': '2018-10-24'
          }
        }
      ],
      'laaApplnReference': {
        'applicationReference': 'appln001',
        'statusCode': 'AP',
        'statusDescription': 'Application Pending',
        'statusDate': '2018-10-24'
      }
    }
  end

  let(:sqs_payload) do
    {
      maatId: 'appln001',
      caseUrn: '12345',
      jurisdictionType: 'MAGISTRATES',
      asn: 'AA11A12345',
      cjsAreaCode: 16,
      caseCreationDate: '2018-10-25 11:30:00',
      cjsLocation: 'B16BG',
      docLanguage: 'EN',
      isActive: true,
      defendant: {
        forename: 'FirstName',
        surname: 'LastName',
        dateOfBirth: '1970-01-01',
        address_line1: 'address1',
        address_line2: 'address2',
        address_line3: 'address3',
        address_line4: 'address4',
        address_line5: 'address5',
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
            offenceShortTitle: 'Robbery',
            offenceClassification: 'Temporary Offence Classification',
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
              firmName: 'Temporary Firm Name',
              contactName: nil,
              laaOfficeAccount: 'Temporary LAA Office Account',
              legalAidWithdrawalDate: nil
            }]
          }
        ]
      },
      sessions: [{
        courtLocation: 'B16BG',
        dateOfHearing: '2018-11-11',
        postHearingCustody: 'R',
        sessionValidateDate: nil
      }]
    }
  end

  subject { described_class.call(shared_time: shared_time, jurisdiction_type: jurisdiction_type, case_status: case_status, case_urn: case_urn, defendant: defendant) }

  before do
    allow(Rails.configuration.x.aws).to receive(:sqs_url_hearing).and_return('/hearing-sqs-url')
  end

  it 'triggers a publish call with the sqs payload' do
    expect(Sqs::MessagePublisher).to receive(:call).with(message: sqs_payload, queue_url: '/hearing-sqs-url')
    subject
  end
end
