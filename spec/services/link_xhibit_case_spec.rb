RSpec.describe LinkXhibitCase, type: :service do
  describe "#call" do
    let(:maat_response) { instance_double(MaatApi::SearchResponse, maat_id: "6559879") }
    let(:xhibit_case) do
      XhibitMigratedCase.create!(
        case_urn: "20GD021701",
        xhibit_case_number: "T202540001",
        court_name: "Derby Justice Centre",
        ou_code: "B30PI00",
        case_type: "T",
        defendant_id: "defendant-1",
        defendant_first_name: "Alice",
        defendant_last_name: "Smith",
        sent_date: Date.new(2019, 10, 25),
      )
    end

    let(:link_case) { described_class.new.call(maat_response, xhibit_case) }

    before do
      allow(CourtApplicationMaatLinkCreator).to receive(:call)
    end

    it "updates the xhibit case" do
      expect { link_case }.to change { xhibit_case.reload.status }.from("pending").to("auto_linked")
                          .and change { xhibit_case.reload.maat_id }.from(nil).to(maat_response.maat_id)
                          .and change { xhibit_case.reload.linked_by }.from(nil).to("SYSTEM")
                          .and change { xhibit_case.reload.linked_at }.from(nil).to(within(1.second).of(Time.zone.now))
    end

    it "calls the CourtApplicationMaatLinkCreator" do
      link_case

      expect(CourtApplicationMaatLinkCreator).to have_received(:call).with(
        xhibit_case.defendant_id,
        "SYSTEM",
        maat_response.maat_id,
      )
    end
  end
end
