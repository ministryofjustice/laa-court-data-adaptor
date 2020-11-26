# frozen_string_literal: true

RSpec.describe CommonPlatform::PostcodeValidator do
  let(:postcode) { "EC4A 2AH" }

  subject { described_class.call(postcode: postcode) }

  it "validates successfully against the common platform postcode format" do
    is_expected.to be_truthy
  end

  context "invalid postcode" do
    let(:postcode) { "EC4A2AH" }

    it "fails validation" do
      is_expected.to be_falsey
    end
  end
end
