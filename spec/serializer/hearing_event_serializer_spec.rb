# frozen_string_literal: true

RSpec.describe HearingEventSerializer do
  subject(:serializable_hash) { described_class.new(hearing_event).serializable_hash }

  let(:hearing_event) do
    instance_double('HearingEvent',
                    id: 'UUID',
                    description: 'Hearing type changed to Plea')
  end

  context 'data' do
    subject(:data) { serializable_hash[:data] }

    it { is_expected.to include(id: 'UUID') }
    it { is_expected.to include(type: :hearing_events) }
    it { is_expected.to have_key(:attributes) }
  end

  context 'data attributes' do
    subject(:data_attributes) { serializable_hash[:data][:attributes] }

    it { expect(data_attributes[:description]).to eq('Hearing type changed to Plea') }
  end
end
