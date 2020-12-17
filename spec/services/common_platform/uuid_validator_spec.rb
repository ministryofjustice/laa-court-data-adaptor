# frozen_string_literal: true

RSpec.describe CommonPlatform::UuidValidator do
  subject(:common_platform_uuid_validator_response) { described_class.call(uuid: uuid) }

  let(:uuid) { "2bf540ff-67d7-487e-a21d-5913d6fa1b9a" }

  it "validates successfully against the common platform uuid format" do
    expect(common_platform_uuid_validator_response).to be_truthy
  end

  context "with invalid uuid" do
    let(:uuid) { "2bf540ff-67d7-487e-a21d" }

    it "fails validation" do
      expect(common_platform_uuid_validator_response).to be_falsey
    end
  end
end
