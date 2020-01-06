# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::RecordLaaReference do
  subject { described_class.call(params) }

  let(:laa_reference_id) { 'f94ab249-21a6-4f63-ae86-f76353256696' }

  let(:params) do
    {
      laa_reference_id: laa_reference_id,
      prosecution_case_id: 'b9950946-fe3b-4eaa-9f0a-35e497e34528',
      defendant_id: '23d7f10a-067a-476e-bba6-bb855674e23b',
      offence_id: '147fed98-ba8a-46cb-b2b4-7c41cf4734bf',
      status_code: 'ABCDEF',
      application_reference: 'SOME SORT OF MAAT ID',
      status_date: '2019-12-12'
    }
  end

  it 'returns a no content status' do
    VCR.use_cassette('laa_reference_recorder/update') do
      expect(subject.status).to eq(204)
    end
  end

  context 'when the LaaReference does not exist' do
    let(:laa_reference_id) { 'a21574ea-74c2-4d20-9cce-3f1c64be701b' }

    it 'returns a created status' do
      VCR.use_cassette('laa_reference_recorder/create') do
        expect(subject.status).to eq(201)
      end
    end
  end

  context 'bad request' do
    let(:params) do
      {
        laa_reference_id: laa_reference_id,
        prosecution_case_id: 'invalid uuid',
        defendant_id: 'invalid uuid',
        offence_id: 'invalid uuid',
        status_code: 'ABCDE',
        application_reference: 'SOME SORT OF MAAT ID',
        status_date: '2019-12-12'
      }
    end

    it 'returns a bad request status' do
      VCR.use_cassette('laa_reference_recorder/error') do
        expect(subject.status).to eq(400)
      end
    end
  end
end
