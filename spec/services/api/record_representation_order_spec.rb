# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::RecordRepresentationOrder do
  subject { described_class.call(params) }

  let(:laa_reference_id) { 'f94ab249-21a6-4f63-ae86-f76353256696' }
  let(:prosecution_case_id) { 'b9950946-fe3b-4eaa-9f0a-35e497e34528' }
  let(:defence_organisation) do
    {
      organisation: {
        name: 'SOME ORGANISATION'
      },
      laaContractNumber: 'CONTRACT REFERENCE'
    }
  end

  let(:params) do
    {
      laa_reference_id: laa_reference_id,
      prosecution_case_id: prosecution_case_id,
      defendant_id: '23d7f10a-067a-476e-bba6-bb855674e23b',
      offence_id: '147fed98-ba8a-46cb-b2b4-7c41cf4734bf',
      status_code: 'ABCDEF',
      application_reference: 'SOME SORT OF MAAT ID',
      status_date: '2019-12-12',
      effective_start_date: '2019-12-15',
      defence_organisation: defence_organisation
    }
  end

  let(:api_request_url) { '/prosecutionCases/representationOrder/f94ab249-21a6-4f63-ae86-f76353256696' }

  it_has_a 'correct api request url'

  it 'returns a no content status' do
    VCR.use_cassette('representation_order_recorder/update') do
      expect(subject.status).to eq(204)
    end
  end

  context 'when the LaaReference does not exist' do
    let(:laa_reference_id) { '0beb2337-60f9-4bb7-b9b0-d83e5487c198' }

    it 'returns a created status' do
      VCR.use_cassette('representation_order_recorder/create') do
        expect(subject.status).to eq(201)
      end
    end
  end

  context 'bad request' do
    let(:prosecution_case_id) { 'invalid uuid' }

    it 'returns a bad request status' do
      VCR.use_cassette('representation_order_recorder/error') do
        expect(subject.status).to eq(400)
      end
    end
  end
end
