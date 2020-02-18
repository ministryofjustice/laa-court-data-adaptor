# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProsecutionCaseSerializer do
  let(:prosecution_case) do
    instance_double('ProsecutionCase',
                    id: 'UUID',
                    prosecution_case_reference: 'AAA',
                    defendant_ids: ['UUID'],
                    hearing_summary_ids: ['UUID'])
  end

  subject { described_class.new(prosecution_case).serializable_hash }

  context 'attributes' do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:prosecution_case_reference]).to eq('AAA') }
  end
end
