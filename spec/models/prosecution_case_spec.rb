# frozen_string_literal: true

RSpec.describe ProsecutionCase, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:body) }
  end

  describe 'Common Platform search' do
    let(:prosecution_case) do
      VCR.use_cassette('search_prosecution_case/by_prosecution_case_reference_success') do
        Api::SearchProsecutionCase.call(prosecution_case_reference: 'TFL12345').first
      end
    end

    it { expect(prosecution_case.prosecution_case_reference).to eq('TFL12345') }
  end
end
