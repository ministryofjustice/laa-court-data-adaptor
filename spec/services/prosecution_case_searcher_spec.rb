# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProsecutionCaseSearcher do
  subject(:search) { described_class.call(prosecution_case_reference) }

  let(:prosecution_case_reference) { '3658e889-e050-4608-8f21-8bdaa529f8d0' }

  it 'returns an array of Prosecution Cases' do
    VCR.use_cassette('prosecution_case_searcher/success') do
      expect(search.status).to eq(200)
      expect(search.body['prosecutionCases']).to be_an(Array)
    end
  end

  it 'the first result is the searched prosecution case' do
    VCR.use_cassette('prosecution_case_searcher/success') do
      expect(search.body['prosecutionCases'].first).to include(
        'prosecutionCaseReference' => prosecution_case_reference
      )
    end
  end

  context 'when searching for an inexistent reference' do
    let(:prosecution_case_reference) { 'prosecution-case-5678' }

    it 'returns an array of Prosecution Cases' do
      VCR.use_cassette('prosecution_case_searcher/not_found') do
        expect(search.status).to eq(200)
        expect(search.body['prosecutionCases']).to be_an(Array)
      end
    end

    it 'there are no results for the search' do
      VCR.use_cassette('prosecution_case_searcher/not_found') do
        expect(search.body['prosecutionCases']).to be_empty
      end
    end
  end
end
