# frozen_string_literal: true

RSpec.describe ProsecutionCaseSerializer do
  let(:prosecution_case) do
    instance_double('ProsecutionCase',
                    id: 'UUID',
                    prosecution_case_reference: 'AAA',
                    defendant_ids: ['DEFENDANT-UUID'])
  end

  subject { described_class.new(prosecution_case).serializable_hash }

  context 'attributes' do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:prosecution_case_reference]).to eq('AAA') }
  end

  context 'relationships' do
    let(:relationship_hash) { subject[:data][:relationships] }

    it { expect(relationship_hash[:defendants][:data]).to eq([id: 'DEFENDANT-UUID', type: :defendants]) }
  end
end
