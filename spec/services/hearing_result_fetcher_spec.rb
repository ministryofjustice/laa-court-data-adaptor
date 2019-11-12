# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HearingResultFetcher do
  subject { described_class.call(hearing_id) }

  let(:hearing_id) { 'ceb158e3-7171-40ce-915b-441e2c4e3f75' }

  it 'returns the requested hearing info' do
    VCR.use_cassette('hearing_result_fetcher/success') do
      expect(subject.body['hearing']['id']).to eq(hearing_id)
    end
  end

  context 'with a non existent id' do
    let(:hearing_id) { '6c0b7068-d4a7-4adc-a7a0-7bd5715b501d' }

    it 'returns a not found response' do
      VCR.use_cassette('hearing_result_fetcher/not_found') do
        expect(subject.status).to eq(404)
      end
    end
  end
end
