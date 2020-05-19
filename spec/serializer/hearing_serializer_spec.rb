# frozen_string_literal: true

RSpec.describe HearingSerializer do
  let(:hearing_summary) do
    instance_double('Hearing',
                    id: 'UUID',
                    court_name: 'Bexley Court',
                    hearing_type: 'First hearing',
                    defendant_names: ['Treutel', 'Alfredine Parker'])
  end

  subject { described_class.new(hearing_summary).serializable_hash }

  context 'attributes' do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:court_name]).to eq('Bexley Court') }
    it { expect(attribute_hash[:hearing_type]).to eq('First hearing') }
    it { expect(attribute_hash[:defendant_names]).to eq(['Treutel', 'Alfredine Parker']) }
  end
end
