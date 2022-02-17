RSpec.describe HmctsCommonPlatform::OffenceSummary, type: :model do
  let(:offence_summary) { described_class.new(data) }

  context "with all fields" do
    let(:data) { JSON.parse(file_fixture("offence_summary/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:offence_summary)
    end

    it { expect(offence_summary.offence_id).to eq("9aca847f-da4e-444b-8f5a-2ce7d776ab75") }
    it { expect(offence_summary.code).to eq("TH68026C") }
    it { expect(offence_summary.title).to eq("Conspire to commit a burglary dwelling with intent to steal") }
    it { expect(offence_summary.order_index).to eq(1) }
    it { expect(offence_summary.mode_of_trial).to eq("Indictable") }
    it { expect(offence_summary.start_date).to eq("2021-03-06") }
    it { expect(offence_summary.wording).to eq("Between 06.03.2021 and 22.03.2021 at DERBY in the county of DERBYSHIRE, conspired together with John Doe to enter as a trespasser") }
    it { expect(offence_summary.laa_reference).to be_an(HmctsCommonPlatform::LaaReference) }
    it { expect(offence_summary.verdict).to be_an(HmctsCommonPlatform::Verdict) }
    it { expect(offence_summary.plea).to be_an(HmctsCommonPlatform::Plea) }
  end

  context "with required fields only" do
    let(:data) { JSON.parse(file_fixture("offence_summary/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:offence_summary)
    end

    it { expect(offence_summary.offence_id).to eq("9aca847f-da4e-444b-8f5a-2ce7d776ab75") }
    it { expect(offence_summary.code).to eq("TH68026C") }
    it { expect(offence_summary.title).to eq("Conspire to commit a burglary dwelling with intent to steal") }
    it { expect(offence_summary.order_index).to be_nil }
    it { expect(offence_summary.mode_of_trial).to be_nil }
    it { expect(offence_summary.start_date).to be_nil }
    it { expect(offence_summary.wording).to be_nil }
    it { expect(offence_summary.laa_reference).to be_blank }
    it { expect(offence_summary.verdict).to be_blank }
    it { expect(offence_summary.plea).to be_blank }
  end

  describe "#to_json" do
    let(:data) { JSON.parse(file_fixture("offence_summary/all_fields.json").read) }

    it "generates a JSON representation of the data" do
      json = offence_summary.to_json

      expect(json["id"]).to eql("9aca847f-da4e-444b-8f5a-2ce7d776ab75")
      expect(json["code"]).to eql("TH68026C")
      expect(json["order_index"]).to be(1)
      expect(json["title"]).to eql("Conspire to commit a burglary dwelling with intent to steal")
      expect(json["legislation"]).to eql("Contrary to section 1(1) of the Criminal Law Act 1977.")
      expect(json["wording"]).to eql("Between 06.03.2021 and 22.03.2021 at DERBY in the county of DERBYSHIRE, conspired together with John Doe to enter as a trespasser")
      expect(json["arrest_date"]).to eql("2021-03-23")
      expect(json["charge_date"]).to eql("2021-03-24")
      expect(json["mode_of_trial"]).to eql("Indictable")
      expect(json["start_date"]).to eql("2021-03-06")
      expect(json["proceedings_concluded"]).to be false
      expect(json["laa_application"]).to be_present
      expect(json["verdict"]).to be_present
      expect(json["plea"]).to be_present
    end
  end
end
