RSpec.describe HmctsCommonPlatform::Offence, type: :model do
  let(:offence) { described_class.new(data) }

  context "when offence has all fields" do
    let(:data) { JSON.parse(file_fixture("offence/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:offence)
    end

    it "generates a JSON representation of the data" do
      expect(offence.to_json["id"]).to eql("3f153786-f3cf-4311-bc0c-2d6f48af68a1")
      expect(offence.to_json["code"]).to eql("LA12505")
      expect(offence.to_json["order_index"]).to be(1)
      expect(offence.to_json["title"]).to eql("Driver / other person fail to immediately move a vehicle from a cordoned area on order of a constable")
      expect(offence.to_json["legislation"]).to eql("Common law")
      expect(offence.to_json["mode_of_trial"]).to eql("Either way")
      expect(offence.to_json["start_date"]).to eql("2019-10-17")
      expect(offence.to_json["wording"]).to eql("Random string")
    end

    it { expect(offence.id).to eql("3f153786-f3cf-4311-bc0c-2d6f48af68a1") }
    it { expect(offence.code).to eql("LA12505") }
    it { expect(offence.order_index).to be(1) }
    it { expect(offence.title).to eql("Driver / other person fail to immediately move a vehicle from a cordoned area on order of a constable") }
    it { expect(offence.legislation).to eql("Common law") }
    it { expect(offence.mode_of_trial).to eql("Either way") }
    it { expect(offence.start_date).to eql("2019-10-17") }
    it { expect(offence.wording).to eql("Random string") }
    it { expect(offence.allocation_decision_mot_reason_code).to eql("5") }
    it { expect(offence.laa_application_status_code).to eql("AP") }
    it { expect(offence.laa_application_status_date).to eql("2020-11-05") }
    it { expect(offence.laa_application_effective_end_date).to eql("2021-04-11") }
    it { expect(offence.laa_application_status_description).to eql("LAA status description") }
    it { expect(offence.laa_application_laa_contract_number).to eql("27900") }
    it { expect(offence.judicial_result_ids).to eql(%w[5cb61858-7095-42d6-8a52-966593f17db0]) }

    it { expect(offence.judicial_results).to all(be_an(HmctsCommonPlatform::JudicialResult)) }
    it { expect(offence.plea).to be_an(HmctsCommonPlatform::Plea) }
    it { expect(offence.verdict).to be_an(HmctsCommonPlatform::Verdict) }
  end

  context "when offence has only required fields" do
    let(:data) { JSON.parse(file_fixture("offence/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:offence)
    end

    it { expect(data).to match_json_schema(:offence) }
    it { expect(offence.id).to eql("3f153786-f3cf-4311-bc0c-2d6f48af68a1") }
    it { expect(offence.code).to eql("LA12505") }
    it { expect(offence.order_index).to be_nil }
    it { expect(offence.title).to eql("Driver / other person fail to immediately move a vehicle from a cordoned area on order of a constable") }
    it { expect(offence.legislation).to be_nil }
    it { expect(offence.mode_of_trial).to be_nil }
    it { expect(offence.start_date).to eql("2019-10-17") }
    it { expect(offence.wording).to eql("Random string") }
    it { expect(offence.allocation_decision_mot_reason_code).to be_nil }
    it { expect(offence.laa_application_status_code).to be_nil }
    it { expect(offence.laa_application_status_date).to be_nil }
    it { expect(offence.laa_application_effective_end_date).to be_nil }
    it { expect(offence.laa_application_status_description).to be_nil }
    it { expect(offence.judicial_results).to eql([]) }
    it { expect(offence.plea).to be_blank }
    it { expect(offence.verdict).to be_blank }
  end
end
