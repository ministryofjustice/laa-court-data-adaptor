# frozen_string_literal: true

RSpec.describe HearingSummarySerializer do
  let(:hearing_summary) do
    instance_double('HearingSummary',
                    id: 'UUID',
                    hearing_type: 'Committal for Sentencing',
                    hearing_days: ['2020-02-01'])
  end

  subject { described_class.new(hearing_summary).serializable_hash }

  context 'attributes' do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:hearing_type]).to eq('Committal for Sentencing') }
    it { expect(attribute_hash[:hearing_days]).to eq(['2020-02-01']) }
  end
end
