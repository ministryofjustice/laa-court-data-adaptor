RSpec.describe LinkXhibitCase, type: :service do
  describe "#call" do
    let(:maat_response) { instance_double(MaatApi::SearchResponse, maat_id: "6559879") }
    let(:case_type) { "T" }
    let(:application_summaries) { [] }
    let(:subject_id) { "b7c8e2f0-0000-4000-8000-000000000002" }

    let(:court_data) do
      instance_double(
        HmctsCommonPlatform::DefendantSummary,
        defendant_id: "b7c8e2f0-0000-4000-8000-000000000001",
        application_summaries:,
      )
    end

    let(:xhibit_case) do
      XhibitMigratedCase.create!(
        case_urn: "20GD021701",
        xhibit_case_number: "T202540001",
        court_name: "Derby Justice Centre",
        ou_code: "B30PI00",
        case_type:,
        defendant_id: "defendant-1",
        defendant_first_name: "Alice",
        defendant_last_name: "Smith",
        sent_date: Date.new(2019, 10, 25),
      )
    end

    let(:link_case) { described_class.call(maat_response, xhibit_case, court_data) }

    before do
      allow(ProsecutionCaseMaatLinkCreator).to receive(:call)
      allow(CourtApplicationMaatLinkCreator).to receive(:call)
    end

    it "updates the xhibit case" do
      expect { link_case }.to change { xhibit_case.reload.status }.from("pending").to("auto_linked")
                          .and change { xhibit_case.reload.maat_id }.from(nil).to(maat_response.maat_id)
                          .and change { xhibit_case.reload.linked_by }.from(nil).to("SYSTEM")
                          .and change { xhibit_case.reload.linked_at }.from(nil).to(within(1.second).of(Time.zone.now))
    end

    it "links a trial using the defendant id" do
      link_case

      expect(ProsecutionCaseMaatLinkCreator).to have_received(:call).with(
        court_data.defendant_id, "SYSTEM", maat_response.maat_id
      )
    end

    %w[A S].each do |court_application_case_type|
      context "when the case type is #{court_application_case_type}" do
        let(:case_type) { court_application_case_type }
        let(:application_summaries) do
          [
            instance_double(
              HmctsCommonPlatform::ApplicationSummary,
              subject_summary: instance_double(HmctsCommonPlatform::SubjectSummary, subject_id:),
            ),
          ]
        end

        it "links the court application using the subject id" do
          link_case

          expect(CourtApplicationMaatLinkCreator).to have_received(:call).with(
            subject_id, "SYSTEM", maat_response.maat_id
          )
        end
      end
    end

    context "when a court application case has no matching application" do
      let(:case_type) { "A" }

      it "raises rather than marking the case linked" do
        expect { link_case }.to raise_error(ArgumentError, /No court application found/)
        expect(xhibit_case.reload).to be_pending
      end
    end

    context "when the case type is not recognised" do
      let(:case_type) { "X" }

      it "raises rather than marking the case linked" do
        expect { link_case }.to raise_error(ArgumentError, /Unsupported case type/)
        expect(xhibit_case.reload).to be_pending
      end
    end
  end
end
