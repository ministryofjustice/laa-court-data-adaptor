# frozen_string_literal: true

RSpec.describe Api::Internal::V2::HearingEventSerializer do
  subject(:serializable_hash) { described_class.new(hearing_event).serializable_hash }

  let(:hearing_event) do
    instance_double("HearingEvent",
                    id: "UUID",
                    description: "Hearing type changed to Plea",
                    occurred_at: "2020-04-30T16:17:58.610Z",
                    note: "Test note")
  end

  context "with data" do
    subject(:data) { serializable_hash[:data] }

    it { is_expected.to include(id: "UUID") }
    it { is_expected.to include(type: :hearing_events) }
    it { is_expected.to have_key(:attributes) }
  end

  context "with data attributes" do
    subject(:data_attributes) { serializable_hash[:data][:attributes] }

    it { expect(data_attributes[:description]).to eq("Hearing type changed to Plea") }
    it { expect(data_attributes[:occurred_at]).to eq("2020-04-30T16:17:58.610Z") }
    it { expect(data_attributes[:note]).to eq("Test note") }
  end
end
