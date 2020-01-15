# frozen_string_literal: true

RSpec.describe Hearing, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:body) }
  end
end
