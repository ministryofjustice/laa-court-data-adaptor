RSpec.describe HmctsCommonPlatform::CourtApplicationSummary, type: :model do
  let(:court_application_summary) { described_class.new(data) }
  let(:data) { JSON.parse(file_fixture("court_application_summary.json").read) }

  it "generates a JSON representation of the data" do
    expect(court_application_summary.to_json["application_id"]).to eql("00004c9f-af9f-401a-b88b-78a4f0e08163")
    expect(court_application_summary.to_json["application_reference"]).to eql("29GD7216523")
    expect(court_application_summary.to_json["application_status"]).to eql("FINALISED")
    expect(court_application_summary.to_json["application_title"]).to eql("Appeal against conviction by a Magistrates' Court to the Crown Court")
    expect(court_application_summary.to_json["application_type"]).to eql("MC80802")
    expect(court_application_summary.to_json["application_category"]).to be(:appeal)
    expect(court_application_summary.to_json["application_result"]).to eql("AACD")
    expect(court_application_summary.to_json["received_date"]).to eql("2023-06-27")
    expect(court_application_summary.to_json["short_id"]).to eql("A25ABCDE1234")
    expect(court_application_summary.to_json["case_summary"]).to be_a(Array)
    expect(court_application_summary.to_json["hearing_summary"]).to be_a(Array)
    expect(court_application_summary.to_json["subject_summary"]).to be_a(Hash)
    expect(court_application_summary.to_json["judicial_results"]).to be_a(Array)
  end

  it { expect(court_application_summary.application_id).to eql("00004c9f-af9f-401a-b88b-78a4f0e08163") }
  it { expect(court_application_summary.application_reference).to eql("29GD7216523") }
  it { expect(court_application_summary.application_status).to eql("FINALISED") }
  it { expect(court_application_summary.application_title).to eql("Appeal against conviction by a Magistrates' Court to the Crown Court") }
  it { expect(court_application_summary.application_type).to eql("MC80802") }
  it { expect(court_application_summary.application_category).to be(:appeal) }
  it { expect(court_application_summary.supported?).to be true }
  it { expect(court_application_summary.application_result).to eql("AACD") }
  it { expect(court_application_summary.received_date).to eql("2023-06-27") }
  it { expect(court_application_summary.short_id).to eql("A25ABCDE1234") }
  it { expect(court_application_summary.case_summary.first).to be_a(HmctsCommonPlatform::CaseSummary) }
  it { expect(court_application_summary.hearing_summary.first).to be_a(HmctsCommonPlatform::HearingSummary) }
  it { expect(court_application_summary.subject_summary).to be_a(HmctsCommonPlatform::SubjectSummary) }
  it { expect(court_application_summary.judicial_results.first).to be_a(HmctsCommonPlatform::JudicialResult) }

  context "when data is presented as a string" do
    let(:data) { file_fixture("court_application_summary.json").read }

    it "generates a transformed JSON representation of the data" do
      expect(court_application_summary.to_json["application_id"]).to eql("00004c9f-af9f-401a-b88b-78a4f0e08163")
      expect(court_application_summary.to_json["application_reference"]).to eql("29GD7216523")
      expect(court_application_summary.to_json["application_status"]).to eql("FINALISED")
      expect(court_application_summary.to_json["application_title"]).to eql("Appeal against conviction by a Magistrates' Court to the Crown Court")
      expect(court_application_summary.to_json["application_type"]).to eql("MC80802")
      expect(court_application_summary.to_json["received_date"]).to eql("2023-06-27")
      expect(court_application_summary.to_json["case_summary"]).to be_a(Array)
      expect(court_application_summary.to_json["hearing_summary"]).to be_a(Array)
      expect(court_application_summary.to_json["subject_summary"]).to be_a(Hash)
      expect(court_application_summary.to_json["judicial_results"]).to be_a(Array)
    end
  end

  describe "#supported?" do
    subject(:supported) { court_application_summary.supported? }

    context "when type is breach" do
      let(:data) { { "applicationType" => "SE20521" } }

      context "when flag is switched off" do
        it { is_expected.to be false }
      end

      context "when flag is switched on" do
        around do |example|
          ENV["NO_OFFENCE_COURT_APPLICATIONS"] = "true"
          example.run
          ENV.delete("NO_OFFENCE_COURT_APPLICATIONS")
        end

        it { is_expected.to be true }
      end
    end
  end

  describe "#judicial_results" do
    subject(:judicial_results) { court_application_summary.judicial_results }

    let(:hearing_result_body) { JSON.parse(file_fixture("hearing/all_fields.json").read) }

    context "when the application is a breach" do
      before do
        data.delete("judicialResults")
        data["applicationType"] = "SE20521"

        allow(CommonPlatform::Api::GetHearingResults).to receive(:call)
          .and_return("hearing" => hearing_result_body)
      end

      it "calls the Common Platform API to retrieve the latest hearing" do
        judicial_results
        expect(CommonPlatform::Api::GetHearingResults).to have_received(:call).with(
          hearing_id: "bacbd19f-c61c-464c-aebc-ef00454e11ca",
        )
      end

      it "returns the judicial results from that call" do
        expect(judicial_results.length).to eq 1
        expect(judicial_results.first.label).to eq "Legal Aid Transfer Granted"
      end

      context "when there are no hearings" do
        before do
          data["hearingSummary"] = []
        end

        it { is_expected.to eq [] }
      end

      context "when hearing is not available" do
        let(:hearing_result_body) { {} }

        it { is_expected.to eq [] }
      end
    end
  end
end
