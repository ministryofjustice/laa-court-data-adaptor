# frozen_string_literal: true

RSpec.describe Api::RecordLaaReference do
  subject { described_class.call(params) }

  let(:prosecution_case_id) { 'b9950946-fe3b-4eaa-9f0a-35e497e34528' }
  let(:defendant_id) { '23d7f10a-067a-476e-bba6-bb855674e23b' }
  let(:offence_id) { '147fed98-ba8a-46cb-b2b4-7c41cf4734bf' }

  let(:params) do
    {
      prosecution_case_id: prosecution_case_id,
      defendant_id: defendant_id,
      offence_id: offence_id,
      status_code: 'ABCDEF',
      application_reference: 'SOME SORT OF MAAT ID',
      status_date: '2019-12-12'
    }
  end
  let(:url) { "/record/laareference-sit/progression-command-api/command/api/rest/progression/laaReference/cases/#{prosecution_case_id}/defendants/#{defendant_id}/offences/#{offence_id}" }

  it 'returns a no content status' do
    VCR.use_cassette('laa_reference_recorder/update') do
      expect(subject.status).to eq(204)
    end
  end

  context 'connection' do
    let(:connection) { double('CommonPlatformConnection') }
    let(:headers) { { 'LAAReference-Subscription-Key' => 'SECRET KEY' } }
    let(:request_params) do
      {
        statusCode: 'ABCDEF',
        applicationReference: 'SOME SORT OF MAAT ID',
        statusDate: '2019-12-12'
      }
    end

    before { params.merge!(shared_key: 'SECRET KEY', connection: connection) }

    it 'makes a post request' do
      expect(connection).to receive(:post).with(url, request_params, headers)
      subject
    end
  end
end
