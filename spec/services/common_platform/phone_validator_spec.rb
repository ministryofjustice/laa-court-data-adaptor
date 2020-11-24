# frozen_string_literal: true

RSpec.describe CommonPlatform::PhoneValidator do
  let(:phone) { "+999999" }

  subject { described_class.call(phone: phone) }

  it "validates successfully against the common platform phone format" do
    is_expected.to be_truthy
  end

  context "invalid phone" do
    let(:phone) { "random" }

    it "fails validation" do
      is_expected.to be_falsey
    end
  end
end
