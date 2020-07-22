# frozen_string_literal: true

RSpec.describe Api::RecordLaaReference do
  subject { described_class.call(params) }

  let(:prosecution_case) { ProsecutionCase.create!(id: '5edd67eb-9d8c-44f2-a57e-c8d026defaa4', body: '{}') }
  let(:defendant_id) { '2ecc9feb-9407-482f-b081-d9e5c8ba3ed3' }
  let(:offence_id) { '3f153786-f3cf-4311-bc0c-2d6f48af68a1' }
  let(:maat_reference) { 999_999 }

  let(:params) do
    {
      prosecution_case_id: prosecution_case.id,
      defendant_id: defendant_id,
      offence_id: offence_id,
      status_code: 'ABCDEF',
      application_reference: maat_reference,
      status_date: '2019-12-12'
    }
  end
  let(:url) { "prosecutionCases/laaReference/cases/#{prosecution_case.id}/defendant/#{defendant_id}/offences/#{offence_id}" }

  let!(:case_defendant_offence) do
    ProsecutionCaseDefendantOffence.create!(prosecution_case_id: prosecution_case.id,
                                            defendant_id: defendant_id,
                                            offence_id: offence_id)
  end

  it 'returns an accepted status' do
    VCR.use_cassette('laa_reference_recorder/update') do
      expect(subject.status).to eq(202)
    end
  end

  context 'connection' do
    let(:connection) { double('CommonPlatformConnection') }
    let(:request_params) do
      {
        statusCode: 'ABCDEF',
        applicationReference: '999999',
        statusDate: '2019-12-12'
      }
    end

    before do
      allow(connection).to receive(:post).and_return(Faraday::Response.new(status: 202, body: { 'test' => 'test' }))
      params.merge!(connection: connection)
    end

    it 'makes a post request' do
      expect(connection).to receive(:post).with(url, request_params)
      subject
    end

    it 'updates the database record for the offence' do
      subject
      case_defendant_offence.reload
      expect(case_defendant_offence.status_date).to eq '2019-12-12'
      expect(case_defendant_offence.rep_order_status).to eq 'ABCDEF'
      expect(case_defendant_offence.response_status).to eq(202)
      expect(case_defendant_offence.response_body).to eq({ 'test' => 'test' })
    end
  end
end
