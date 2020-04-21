# frozen_string_literal: true

RSpec.describe ProsecutionCaseSearcher do
  let(:prosecution_case_reference) { 'TFL12345' }

  context 'with an incorrect key' do
    subject { described_class.call(prosecution_case_reference: prosecution_case_reference, shared_key: 'INCORRECT KEY') }

    it 'returns an unauthorised response' do
      VCR.use_cassette('search_prosecution_case/unauthorised') do
        expect(subject.status).to eq(401)
      end
    end
  end

  context 'searching by ProsecutionCase Reference' do
    subject(:search) { described_class.call(prosecution_case_reference: prosecution_case_reference) }

    it 'returns a successful response' do
      VCR.use_cassette('search_prosecution_case/by_prosecution_case_reference_success') do
        expect(subject.status).to eq(200)
        expect(subject.body['cases'][0]['prosecutionCaseReference']).to eq(prosecution_case_reference)
        search
      end
    end
  end

  context 'searching by National Insurance Number' do
    let(:national_insurance_number) { 'BN102966C' }

    subject(:search) { described_class.call(national_insurance_number: national_insurance_number) }

    it 'returns a successful response' do
      VCR.use_cassette('search_prosecution_case/by_national_insurance_number_success') do
        expect(subject.status).to eq(200)
        search
      end
    end
  end

  context 'searching by Arrest Summons Number' do
    let(:arrest_summons_number) { 'arrest123' }

    subject(:search) { described_class.call(arrest_summons_number: arrest_summons_number) }

    it 'returns a successful response' do
      VCR.use_cassette('search_prosecution_case/by_arrest_summons_number_success') do
        expect(subject.status).to eq(200)
        search
      end
    end
  end

  context 'searching by name and date of birth' do
    let(:date_of_birth) { '1971-05-12' }

    subject(:search) { described_class.call(name: 'Alfredine Parker', date_of_birth: date_of_birth) }

    it 'returns a successful response' do
      VCR.use_cassette('search_prosecution_case/by_name_and_date_of_birth_success') do
        expect(subject.status).to eq(200)
        search
      end
    end
  end

  context 'searching by name and date_of_next_hearing' do
    let(:date_of_next_hearing) { '2025-05-04' }

    subject(:search) { described_class.call(name: 'Alfredine Parker', date_of_next_hearing: date_of_next_hearing) }

    it 'returns a successful response' do
      VCR.use_cassette('search_prosecution_case/by_name_and_date_of_next_hearing_success') do
        expect(subject.status).to eq(200)
        search
      end
    end
  end

  context 'connection' do
    subject { described_class.call(prosecution_case_reference: prosecution_case_reference, shared_key: 'SECRET KEY', connection: connection) }

    let(:connection) { double('CommonPlatformConnection') }
    let(:url) { '/prosecutionCases' }
    let(:params) { { prosecutionCaseReference: prosecution_case_reference } }
    let(:headers) { { 'Ocp-Apim-Subscription-Key' => 'SECRET KEY' } }

    it 'makes a get request' do
      expect(connection).to receive(:get).with(url, params, headers)
      subject
    end
  end
end
