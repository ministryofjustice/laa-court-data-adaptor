# frozen_string_literal: true

RSpec.describe CommonPlatform::EmailValidator do
  subject(:common_platform_email_validator_response) { described_class.call(email: email) }

  let(:email) { "abc@example.com" }

  it "validates successfully against the common platform email format" do
    expect(common_platform_email_validator_response).to be_truthy
  end

  context "with invalid email" do
    let(:email) { "random" }

    it "fails validation" do
      expect(common_platform_email_validator_response).to be_falsey
    end
  end
end
