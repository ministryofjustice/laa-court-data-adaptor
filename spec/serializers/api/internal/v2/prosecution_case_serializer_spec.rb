# frozen_string_literal: true

RSpec.describe Api::Internal::V2::ProsecutionCaseSerializer do
  subject { described_class.new(prosecution_case).serializable_hash }

  let(:prosecution_case) do
    instance_double("HMCTSCommonPlatform::ProsecutionCase",
                    id: "UUID",
                    urn: "AAA",
                    defendant_ids: %w[DEFENDANT-UUID])
  end

  context "with attributes" do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:urn]).to eq("AAA") }
  end

  context "with relationships" do
    let(:relationship_hash) { subject[:data][:relationships] }

    it { expect(relationship_hash[:defendants][:data]).to eq([{ id: "DEFENDANT-UUID", type: :defendants }]) }
  end
end
