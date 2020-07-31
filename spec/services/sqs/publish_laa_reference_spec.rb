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
      createdUser: 'bossMan',
      docLanguage: 'EN',
      isActive: false,
      defendant: {
        defendantId: '2ecc9feb-9407-482f-b081-d9e5c8ba3ed3',
        dateOfBirth: '1980-01-01',
        nino: 'HB133542A',
        offences: [
          {
            offenceId: '3f153786-f3cf-4311-bc0c-2d6f48af68a1',
            offenceCode: 'PT00011',
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

  subject { described_class.call(prosecution_case_id: prosecution_case_id, defendant_id: defendant_id, user_name: 'bossMan', maat_reference: maat_reference) }

  let(:queue_url) { Rails.configuration.x.aws.sqs_url_link }

  it 'triggers a publish call with the sqs payload' do
    expect(Sqs::MessagePublisher).to receive(:call).with(message: sqs_payload, queue_url: queue_url).and_call_original
    subject
  end
end
