# frozen_string_literal: true

RSpec.describe CommonPlatform::EmailValidator do
  let(:email) { 'abc@example.com' }

  subject { described_class.call(email: email) }

  it 'validates successfully against the common platform email format' do
    is_expected.to be_truthy
  end

  context 'invalid email' do
    let(:email) { 'random' }

    it 'fails validation' do
      is_expected.to be_falsey
    end
  end
end
