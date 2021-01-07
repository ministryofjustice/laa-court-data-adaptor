# frozen_string_literal: true

RSpec.describe CommonPlatform::PhoneValidator do
  subject(:common_platform_phone_validator_response) { described_class.call(phone: phone) }

  let(:phone) { "+999999" }

  it "validates successfully against the common platform phone format" do
    expect(common_platform_phone_validator_response).to be_truthy
  end

  context "with invalid phone" do
    let(:phone) { "random" }

    it "fails validation" do
      expect(common_platform_phone_validator_response).to be_falsey
    end
  end
end
