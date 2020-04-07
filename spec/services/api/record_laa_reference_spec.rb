# frozen_string_literal: true

RSpec.describe Api::RecordLaaReference do
  subject { described_class.call(params) }

  let(:prosecution_case_id) { 'b9950946-fe3b-4eaa-9f0a-35e497e34528' }
  let(:defendant_id) { '23d7f10a-067a-476e-bba6-bb855674e23b' }
  let(:offence_id) { '147fed98-ba8a-46cb-b2b4-7c41cf4734bf' }
  let(:maat_reference) { 999_999 }

  let(:params) do
    {
      prosecution_case_id: prosecution_case_id,
      defendant_id: defendant_id,
      offence_id: offence_id,
      status_code: 'ABCDEF',
      application_reference: maat_reference,
      status_date: '2019-12-12'
    }
  end
  let(:url) { "/record/laareference/progression-command-api/command/api/rest/progression/laaReference/cases/#{prosecution_case_id}/defendants/#{defendant_id}/offences/#{offence_id}" }

  let!(:case_defendant_offence) do
    ProsecutionCaseDefendantOffence.create!(prosecution_case_id: prosecution_case_id,
                                            defendant_id: defendant_id,
                                            offence_id: offence_id)
  end

  it 'returns a no content status' do
    VCR.use_cassette('laa_reference_recorder/update') do
      expect(subject.status).to eq(204)
    end
  end

  context 'connection' do
    let(:connection) { double('CommonPlatformConnection') }
    let(:headers) { { 'Ocp-Apim-Subscription-Key' => 'SECRET KEY' } }
    let(:request_params) do
      {
        statusCode: 'ABCDEF',
        applicationReference: maat_reference,
        statusDate: '2019-12-12'
      }
    end

    before do
      allow(connection).to receive(:post).and_return(Faraday::Response.new(status: 200, body: { 'test' => 'test' }))
      params.merge!(shared_key: 'SECRET KEY', connection: connection)
    end

    it 'makes a post request' do
      expect(connection).to receive(:post).with(url, request_params, headers)
      subject
    end

    it 'updates the database record for the offence' do
      subject
      case_defendant_offence.reload
      expect(case_defendant_offence.status_date).to eq '2019-12-12'
      expect(case_defendant_offence.maat_reference).to eq '999999'
      expect(case_defendant_offence.dummy_maat_reference).to be false
      expect(case_defendant_offence.rep_order_status).to eq 'ABCDEF'
      expect(case_defendant_offence.response_status).to eq(200)
      expect(case_defendant_offence.response_body).to eq({ 'test' => 'test' })
    end

    context 'with a A series dummy_maat_reference' do
      let(:maat_reference) { 'A999999' }

      it 'sets the dummy_maat_reference to true' do
        subject
        expect(case_defendant_offence.reload.dummy_maat_reference).to be true
      end
    end

    context 'with a Z series dummy_maat_reference' do
      let(:maat_reference) { 'Z999999' }

      it 'sets the dummy_maat_reference to true' do
        subject
        offence_record = ProsecutionCaseDefendantOffence.find_by(defendant_id: defendant_id)
        expect(offence_record.dummy_maat_reference).to be true
      end
    end
  end
end
