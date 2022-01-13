# frozen_string_literal: true

RSpec.describe Api::Internal::V1::ProsecutionCaseSerializer do
  subject { described_class.new(prosecution_case).serializable_hash }

  let(:prosecution_case_summary_data) { JSON.parse(file_fixture("prosecution_case_summary/all_fields.json").read) }
  let(:prosecution_case) { ProsecutionCase.new(body: prosecution_case_summary_data) }

  context "with attributes" do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:prosecution_case_reference]).to eq("30DI0570888") }
  end

  context "with relationships" do
    let(:relationship_hash) { subject[:data][:relationships] }

    it do
      expect(relationship_hash[:defendants][:data]).to eq([
        { id: "b760daba-0d38-4bae-ad57-fbfd8419aefe", type: :defendants },
        { id: "562dc2de-2258-4476-8be4-69cf15623f83", type: :defendants },
      ])
    end
  end
end
