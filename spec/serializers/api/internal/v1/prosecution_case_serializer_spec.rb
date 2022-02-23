# frozen_string_literal: true

RSpec.describe Api::Internal::V1::ProsecutionCaseSerializer do
  subject { described_class.new(prosecution_case).serializable_hash }

  let(:prosecution_case_data) { JSON.parse(file_fixture("prosecution_case/all_fields.json").read) }
  let(:prosecution_case) { HmctsCommonPlatform::ProsecutionCase.new(prosecution_case_data) }

  context "with attributes" do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:prosecution_case_reference]).to eq("20GD0217100") }
  end

  context "with relationships" do
    let(:relationship_hash) { subject[:data][:relationships] }

    it { expect(relationship_hash[:defendants][:data]).to eq([{ id: "2ecc9feb-9407-482f-b081-d9e5c8ba3ed3", type: :defendants }]) }
  end
end
