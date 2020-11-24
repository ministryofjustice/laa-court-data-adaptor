# frozen_string_literal: true

RSpec.describe CommonPlatform::UuidValidator do
  let(:uuid) { "2bf540ff-67d7-487e-a21d-5913d6fa1b9a" }

  subject { described_class.call(uuid: uuid) }

  it "validates successfully against the common platform uuid format" do
    is_expected.to be_truthy
  end

  context "invalid uuid" do
    let(:uuid) { "2bf540ff-67d7-487e-a21d" }

    it "fails validation" do
      is_expected.to be_falsey
    end
  end
end
