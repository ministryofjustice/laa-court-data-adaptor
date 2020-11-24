# frozen_string_literal: true

RSpec.describe HearingSerializer do
  let(:hearing) do
    instance_double("Hearing",
                    id: "UUID",
                    court_name: "Bexley Court",
                    hearing_type: "Committal for Sentencing",
                    hearing_days: %w[2020-02-01],
                    defendant_names: ["Treutel", "Alfredine Parker"],
                    hearing_event_ids: %w[HEARING_EVENT_UUID],
                    judge_names: ["Mr Recorder J Patterson"],
                    prosecution_advocate_names: ["John Rob"],
                    defence_advocate_names: ["Neil Griffiths"],
                    provider_ids: %w[PROVIDER_UUID])
  end

  subject { described_class.new(hearing).serializable_hash }

  context "attributes" do
    let(:attribute_hash) { subject[:data][:attributes] }

    it { expect(attribute_hash[:court_name]).to eq("Bexley Court") }
    it { expect(attribute_hash[:hearing_type]).to eq("Committal for Sentencing") }
    it { expect(attribute_hash[:defendant_names]).to eq(["Treutel", "Alfredine Parker"]) }
    it { expect(attribute_hash[:judge_names]).to eq(["Mr Recorder J Patterson"]) }
    it { expect(attribute_hash[:prosecution_advocate_names]).to eq(["John Rob"]) }
    it { expect(attribute_hash[:defence_advocate_names]).to eq(["Neil Griffiths"]) }
    it { expect(attribute_hash[:hearing_days]).to eq(%w[2020-02-01]) }
  end

  context "relationships" do
    let(:relationship_hash) { subject[:data][:relationships] }

    it { expect(relationship_hash[:hearing_events][:data]).to eq([{ id: "HEARING_EVENT_UUID", type: :hearing_events }]) }
    it { expect(relationship_hash[:providers][:data]).to eq([{ id: "PROVIDER_UUID", type: :providers }]) }
  end
end
