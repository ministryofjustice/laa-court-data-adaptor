# frozen_string_literal: true

RSpec.describe Sqs::PublishLaaReference do
  let(:prosecution_case_id) { '7a0c947e-97b4-4c5a-ae6a-26320afc914d' }
  let(:defendant_id) { '8cd0ba7e-df89-45a3-8c61-4008a2186d64' }
  let!(:prosecution_case) do
    ProsecutionCase.create!(
      id: prosecution_case_id,
      body: JSON.parse(file_fixture('prosecution_case_search_result.json').read)
    )
  end
  let(:maat_reference) { 123_456 }

  let(:sqs_payload) do
    {
      maatId: maat_reference,
      caseUrn: 'TFL12345',
      asn: 'arrest123',
      cjsAreaCode: 16,
      cjsLocation: 'B16BG',
      createdUser: 'cpUser',
      docLanguage: 'EN',
      isActive: false,
      defendant: {
        defendantId: '8cd0ba7e-df89-45a3-8c61-4008a2186d64',
        dateOfBirth: '1971-05-12',
        nino: 'BN102966C',
        offences: [
          {
            offenceCode: 'AA06035',
            modeOfTrial: 1,
            asnSeq: 1,
            offenceShortTitle: 'Random string',
            offenceWording: 'Random string',
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

  it 'triggers a publish call with the sqs payload' do
    expect(Sqs::MessagePublisher).to receive(:call).with(message: sqs_payload)
    subject
  end
end
