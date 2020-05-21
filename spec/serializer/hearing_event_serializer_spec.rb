# frozen_string_literal: true

RSpec.describe HearingEventSerializer do
  let(:hearing_event) do
    instance_double('HearingEvent',
                    id: 'UUID',
                    description: 'Hearing type changed to Plea')
  end

  subject { described_class.new(hearing_event).serializable_hash }

  context 'attributes' do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:description]).to eq('Hearing type changed to Plea') }
  end
end
