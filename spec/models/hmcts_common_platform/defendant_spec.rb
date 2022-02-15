RSpec.describe HmctsCommonPlatform::Defendant, type: :model do
  let(:defendant) { described_class.new(data) }

  context "when the defendant has all fields" do
    let(:data) { JSON.parse(file_fixture("defendant/all_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:defendant)
    end

    it "generates a JSON representation of the data" do
      expect(defendant.to_json["id"]).to eql("70d0817b-2a48-4751-b4a9-b6323874a310")
      expect(defendant.to_json["prosecution_case_id"]).to eql("4028f014-3a57-4e59-b014-f4d4502f7b73")
      expect(defendant.to_json["proceedings_concluded"]).to be false
      expect(defendant.to_json["defendant_details"]).to be_present
      expect(defendant.to_json["offences"]).to be_present
      expect(defendant.to_json["judicial_results"]).to be_present
      expect(defendant.to_json["defence_organisation"]).to be_present
      expect(defendant.to_json["legal_aid_status"]).to eql("aid status")
      expect(defendant.to_json["is_youth"]).to be false
    end

    it { expect(defendant.id).to eql("70d0817b-2a48-4751-b4a9-b6323874a310") }
    it { expect(defendant.prosecution_case_id).to eql("4028f014-3a57-4e59-b014-f4d4502f7b73") }
    it { expect(defendant.proceedings_concluded).to be(false) }
    it { expect(defendant.legal_aid_status).to eql("aid status") }
    it { expect(defendant.is_youth).to be false }
    it { expect(defendant.arrest_summons_number).to eql("TFL1") }
    it { expect(defendant.first_name).to eql("John") }
    it { expect(defendant.last_name).to eql("Yundt") }
    it { expect(defendant.date_of_birth).to eql("1990-01-01") }
    it { expect(defendant.nino).to eql("AA123456C") }
    it { expect(defendant.documentation_language_needs).to eql("ENGLISH") }
    it { expect(defendant.address_1).to eql("Address Line 1") }
    it { expect(defendant.address_2).to eql("Address Line 2") }
    it { expect(defendant.address_3).to eql("Address Line 3") }
    it { expect(defendant.address_4).to eql("Address Line 4") }
    it { expect(defendant.address_5).to eql("Address Line 5") }
    it { expect(defendant.postcode).to eql("SW1H 9EA") }
    it { expect(defendant.phone_home).to eql("000-000-0000") }
    it { expect(defendant.phone_work).to eql("111-111-1111") }
    it { expect(defendant.phone_mobile).to eql("222-222-2222") }
    it { expect(defendant.email_primary).to eql("primary@example.com") }
    it { expect(defendant.email_secondary).to eql("secondary@example.com") }
    it { expect(defendant.offence_ids).to eql(%w[b8ffe7db-f994-45a0-9c06-9ec953eeffd7 b8ffe7db-f994-45a0-9c06-9ec953eeff99]) }
    it { expect(defendant.offences).to all(be_an(HmctsCommonPlatform::Offence)) }
    it { expect(defendant.judicial_result_ids).to eql(%w[be225605-fc15-47aa-b74c-efb8629db58e]) }
    it { expect(defendant.judicial_results).to all(be_an(HmctsCommonPlatform::JudicialResult)) }
    it { expect(defendant.defence_organisation).to be_an(HmctsCommonPlatform::DefenceOrganisation) }
  end

  context "when the defendant has only required fields" do
    let(:data) { JSON.parse(file_fixture("defendant/required_fields.json").read) }

    it "matches the HMCTS Common Platform schema" do
      expect(data).to match_json_schema(:defendant)
    end

    it { expect(defendant.id).to eql("5aa2ba71-01d6-481b-82d3-228d61e6e73d") }
    it { expect(data).to match_json_schema(:defendant) }
    it { expect(defendant.proceedings_concluded).to be_nil }
    it { expect(defendant.arrest_summons_number).to be_nil }
    it { expect(defendant.first_name).to be_nil }
    it { expect(defendant.last_name).to be_nil }
    it { expect(defendant.date_of_birth).to be_nil }
    it { expect(defendant.nino).to be_nil }
    it { expect(defendant.documentation_language_needs).to be_nil }
    it { expect(defendant.address_1).to be_nil }
    it { expect(defendant.address_2).to be_nil }
    it { expect(defendant.address_3).to be_nil }
    it { expect(defendant.address_4).to be_nil }
    it { expect(defendant.address_5).to be_nil }
    it { expect(defendant.postcode).to be_nil }
    it { expect(defendant.phone_home).to be_nil }
    it { expect(defendant.phone_work).to be_nil }
    it { expect(defendant.phone_mobile).to be_nil }
    it { expect(defendant.email_primary).to be_nil }
    it { expect(defendant.email_secondary).to be_nil }
    it { expect(defendant.judicial_results).to be_empty }

    describe "offences" do
      it "are HmctsCommonPlatform::Offence objects" do
        expect(defendant.offences).to all(be_an(HmctsCommonPlatform::Offence))
      end
    end
  end
end
