# frozen_string_literal: true

RSpec.describe Hearing, type: :model do
  let(:hearing) { described_class.new(body: '{}') }
  subject { hearing }

  describe 'validations' do
    it { should validate_presence_of(:body) }

    context 'when the body is missing' do
      before { hearing.body = nil }
      it { should validate_presence_of(:events) }
    end
  end
end
