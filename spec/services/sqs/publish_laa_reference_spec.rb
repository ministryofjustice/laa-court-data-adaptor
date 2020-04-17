# frozen_string_literal: true

RSpec.describe Sqs::PublishLaaReference do
  let(:prosecution_case_id) { '5edd67eb-9d8c-44f2-a57e-c8d026defaa4' }
  let(:defendant_id) { '2ecc9feb-9407-482f-b081-d9e5c8ba3ed3' }
  let!(:prosecution_case) do
    ProsecutionCase.create!(
      id: prosecution_case_id,
      body: JSON.parse(file_fixture('prosecution_case_search_result.json').read)['cases'][0]
    )
  end
  let(:maat_reference) { 123_456 }

  let(:sqs_payload) do
    {
      maatId: maat_reference,
      caseUrn: '20GD0217100',
      asn: 'ARREST123',
      cjsAreaCode: 16,
      cjsLocation: 'B16BG',
      createdUser: 'cpUser',
      docLanguage: 'EN',
      isActive: false,
      defendant: {
        defendantId: '2ecc9feb-9407-482f-b081-d9e5c8ba3ed3',
        dateOfBirth: '1980-01-01',
        nino: 'HB133542A',
        offences: [
          {
            offenceCode: 'AA06035',
            modeOfTrial: 1,
            asnSeq: 1,
            offenceShortTitle: 'Driver / other person fail to immediately move a vehicle from a cordoned area on order of a constable',
            offenceWording: 'Test',
            results: [{
              asnSeq: 1,
              resultCode: 3026
            }]
          }
        ]
      },
      sessions: [{
        courtLocation: 'B16BG',
        dateOfHearing: '2020-08-16',
        postHearingCustody: 'R'
      }]
    }
  end

  subject { described_class.call(prosecution_case_id: prosecution_case_id, defendant_id: defendant_id, maat_reference: maat_reference) }

  before do
    allow(Rails.configuration.x.aws).to receive(:sqs_url_link).and_return('/link-sqs-url')
  end

  it 'triggers a publish call with the sqs payload' do
    expect(Sqs::MessagePublisher).to receive(:call).with(message: sqs_payload, queue_url: '/link-sqs-url')
    subject
  end
end
