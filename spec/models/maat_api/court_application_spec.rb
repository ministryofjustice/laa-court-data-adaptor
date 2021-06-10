RSpec.describe MaatApi::CourtApplication, type: :model do
  let(:shared_time) { "2021-03-09T15:54:09.871Z" }
  let(:maat_reference) { "123" }

  let(:court_application) do
    described_class.new(
      shared_time,
      HmctsCommonPlatform::Hearing.new(hearing_resulted_data[:hearing]),
      HmctsCommonPlatform::CourtApplication.new(hearing_resulted_data.dig(:hearing, :courtApplications).first),
      maat_reference,
    )
  end

  context "with all fields" do
    let(:hearing_resulted_data) { JSON.parse(file_fixture("hearing/with_court_application.json").read).deep_symbolize_keys }

    it "has a maat_reference" do
      expect(court_application.maat_reference).to eql("123")
    end

    it "has no case URN" do
      expect(court_application.case_urn).to be_nil
    end

    it "has a jurisdiction type" do
      expect(court_application.jurisdiction_type).to eql("MAGISTRATES")
    end

    it "has a defendant ASN" do
      expect(court_application.defendant_asn).to eql("TFL1")
    end

    it "has a cjs area code" do
      expect(court_application.cjs_area_code).to eql("1")
    end

    it "has no cjs location" do
      expect(court_application.cjs_location).to eql("B01LY")
    end

    it "has a case creation date" do
      expect(court_application.case_creation_date).to eql("2021-03-09")
    end

    it "has a doc language" do
      expect(court_application.doc_language).to eql("WELSH")
    end

    it "has proceedings_concluded flag" do
      expect(court_application.proceedings_concluded).to be(false)
    end

    it "has no crown_court_outcome" do
      expect(court_application.crown_court_outcome).to be_nil
    end

    it "is always inactive" do
      expect(court_application.inactive).to eql("Y")
    end

    it "has a function type of APPLICATION " do
      expect(court_application.function_type).to eql("APPLICATION")
    end

    it "has a defendant object" do
      expected = {
        forename: "Carlee",
        surname: "WilliamsonConnelly",
        dateOfBirth: "1990-01-01",
        addressLine1: "Address Line 1",
        addressLine2: "Address Line 2",
        addressLine3: "Address Line 3",
        addressLine4: "Address Line 4",
        addressLine5: "Address Line 5",
        postcode: "SW1H 9EA",
        nino: "AA123456C",
        email1: "primary@example.com",
        email2: "secondary@example.com",
        telephoneHome: "000-000-0000",
        telephoneMobile: "222-222-2222",
        telephoneWork: "111-111-1111",
        offences: [
          {
            offenceClassification: "CO",
            offenceCode: "LA12505",
            offenceDate: "2021-03-09",
            offenceId: "74b72f6f-414a-3464-a4a2-d91397b4c439",
            offenceShortTitle: "Application for transfer of legal aid",
            offenceWording: "application particulars - Pursuant to Regulation 14 of the Criminal Legal Aid",
            results: [
              {
                nextHearingDate: "2020-03-01",
                nextHearingLocation: "B01LY",
                resultCode: "4600",
                resultCodeQualifiers: "",
                resultShortTitle: "Legal Aid Transfer Granted",
                resultText: "Legal Aid Transfer Granted\nGrant of legal aid transferred to (new firm name) Joe Bloggs Solicitors Ltd, London\nAdditional reasons Defendant's choice\nNew firm's LAA account reference 55558888",
              },
            ],
          },
        ],
      }

      expect(court_application.defendant).to eql(expected)
    end

    it "has a session object" do
      expected = {
        courtLocation: "B01LY",
        dateOfHearing: "2021-03-10",
        sessionValidateDate: "2021-03-10",
      }

      expect(court_application.session).to eql(expected)
    end
  end

  context "when the hearing has a court application with only the required fields" do
    let(:hearing_resulted_data) do
      JSON.parse(file_fixture("hearing/with_court_application_required_only.json").read).deep_symbolize_keys
    end

    it "has a maat_reference" do
      expect(court_application.maat_reference).to eql("123")
    end

    it "has no case URN" do
      expect(court_application.case_urn).to be_nil
    end

    it "has a jurisdiction type" do
      expect(court_application.jurisdiction_type).to eql("MAGISTRATES")
    end

    it "has a defendant ASN" do
      expect(court_application.defendant_asn).to be_nil
    end

    it "has a cjs area code" do
      expect(court_application.cjs_area_code).to eql("1")
    end

    it "has no cjs location" do
      expect(court_application.cjs_location).to eql("B01LY")
    end

    it "has a case creation date" do
      expect(court_application.case_creation_date).to eql("2021-03-09")
    end

    it "has a doc language" do
      expect(court_application.doc_language).to be_nil
    end

    it "has proceedings_concluded flag" do
      expect(court_application.proceedings_concluded).to be(false)
    end

    it "has no crown_court_outcome" do
      expect(court_application.crown_court_outcome).to be_nil
    end

    it "is always inactive" do
      expect(court_application.inactive).to eql("Y")
    end

    it "has a function type of APPLICATION " do
      expect(court_application.function_type).to eql("APPLICATION")
    end

    it "has a defendant object" do
      expected = {
        forename: nil,
        surname: "WilliamsonConnelly",
        dateOfBirth: nil,
        addressLine1: nil,
        addressLine2: nil,
        addressLine3: nil,
        addressLine4: nil,
        addressLine5: nil,
        postcode: nil,
        nino: nil,
        email1: nil,
        email2: nil,
        telephoneHome: nil,
        telephoneMobile: nil,
        telephoneWork: nil,
        offences: [
          {
            offenceClassification: "CO",
            offenceCode: nil,
            offenceDate: "2021-03-09",
            offenceId: "74b72f6f-414a-3464-a4a2-d91397b4c439",
            offenceShortTitle: "Application for transfer of legal aid",
            offenceWording: nil,
            results: [],
          },
        ],
      }

      expect(court_application.defendant).to eql(expected)
    end
  end
end
