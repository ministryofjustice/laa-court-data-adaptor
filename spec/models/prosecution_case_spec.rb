# frozen_string_literal: true

RSpec.describe ProsecutionCase, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:body) }
  end

  describe 'Common Platform search' do
    let(:prosecution_case) do
      VCR.use_cassette('search_prosecution_case/by_prosecution_case_reference_success') do
        Api::SearchProsecutionCase.call(prosecution_case_reference: '19GD1001816').first
      end
    end

    it { expect(prosecution_case.prosecution_case_reference).to eq('19GD1001816') }
  end
end
