# frozen_string_literal: true

RSpec.describe CommonPlatform::PostcodeValidator do
  subject(:common_platform_postcode_validator_response) { described_class.call(postcode: postcode) }

  let(:postcode) { "EC4A 2AH" }

  it "validates successfully against the common platform postcode format" do
    expect(common_platform_postcode_validator_response).to be_truthy
  end

  context "with invalid postcode" do
    let(:postcode) { "EC4A2AH" }

    it "fails validation" do
      expect(common_platform_postcode_validator_response).to be_falsey
    end
  end
end
