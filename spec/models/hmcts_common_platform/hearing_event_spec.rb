RSpec.describe HmctsCommonPlatform::HearingEvent, type: :model do
  let(:hearing_event) { described_class.new(data) }

  context "when hearing_event has all fields" do
    let(:data) { JSON.parse(file_fixture("hearing_event.json").read) }

    it "generates a JSON representation of the data" do
      expect(hearing_event.to_json["id"]).to eql("b97449bb-5145-4bfc-a8ec-849082406d79")
      expect(hearing_event.to_json["definition_id"]).to eql("b71e7d2a-d3b3-4a55-a393-6d451767fc05")
      expect(hearing_event.to_json["defence_counsel_id"]).to eql("859d95d2-e394-43d0-bef3-c0eb3b1e7cf9")
      expect(hearing_event.to_json["recorded_label"]).to eql("Hearing started")
      expect(hearing_event.to_json["event_time"]).to eql("2020-04-30T16:17:58.610Z")
      expect(hearing_event.to_json["last_modified_time"]).to eql("2020-04-29T16:17:59.409Z")
      expect(hearing_event.to_json["alterable"]).to be false
      expect(hearing_event.to_json["note"]).to eql("Test note 1")
    end

    it { expect(hearing_event.id).to eql("b97449bb-5145-4bfc-a8ec-849082406d79") }
    it { expect(hearing_event.definition_id).to eql("b71e7d2a-d3b3-4a55-a393-6d451767fc05") }
    it { expect(hearing_event.defence_counsel_id).to eql("859d95d2-e394-43d0-bef3-c0eb3b1e7cf9") }
    it { expect(hearing_event.recorded_label).to eql("Hearing started") }
    it { expect(hearing_event.event_time).to eql("2020-04-30T16:17:58.610Z") }
    it { expect(hearing_event.last_modified_time).to eql("2020-04-29T16:17:59.409Z") }
    it { expect(hearing_event.alterable).to be false }
    it { expect(hearing_event.note).to eql("Test note 1") }
  end
end
