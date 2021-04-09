RSpec.describe MaatApi::ProsecutionCase, type: :model do
  subject(:prosecution_case) do
    described_class.new(shared_time, maat_reference, case_urn, hearing, defendant)
  end

  let(:shared_time) { "2021-03-09" }
  let(:maat_reference) { "123" }
  let(:case_urn) { "30DI234234" }

  let(:hearing) do
    data = JSON.parse(file_fixture("hearing/all_fields.json").read).deep_symbolize_keys
    HmctsCommonPlatform::Hearing.new(data[:hearing])
  end

  let(:defendant) do
    data = JSON.parse(file_fixture("defendant/all_fields.json").read).deep_symbolize_keys
    HmctsCommonPlatform::Defendant.new(data)
  end

  it "has a maat_reference" do
    expect(prosecution_case.maat_reference).to eql("123")
  end

  it "has a case URN" do
    expect(prosecution_case.case_urn).to eq("30DI234234")
  end

  it "has a jurisdiction type" do
    expect(prosecution_case.jurisdiction_type).to eql("CROWN")
  end

  it "has a defendant ASN" do
    expect(prosecution_case.defendant_asn).to eql("TFL1")
  end

  it "has a cjs area code" do
    expect(prosecution_case.cjs_area_code).to eql("7")
  end

  it "has a cjs location" do
    expect(prosecution_case.cjs_location).to eql("A07AF")
  end

  it "has a case creation date" do
    expect(prosecution_case.case_creation_date).to eql("2021-03-09")
  end

  it "has a doc language" do
    expect(prosecution_case.doc_language).to eql("WELSH")
  end

  it "has proceedings_concluded flag" do
    expect(prosecution_case.proceedings_concluded).to be(true)
  end

  it "has no crown_court_outcome" do
    expect(prosecution_case.crown_court_outcome).to be_nil
  end

  it "is always inactive" do
    expect(prosecution_case.inactive).to eql("Y")
  end

  it "has a function type of PROSECUTION_CASE " do
    expect(prosecution_case.function_type).to eql("PROSECUTION_CASE")
  end

  describe "defendant object" do
    it "has the expected attributes" do
      expect(prosecution_case.defendant[:forename]).to eq("Carlee")
      expect(prosecution_case.defendant[:surname]).to eq("WilliamsonConnelly")
      expect(prosecution_case.defendant[:dateOfBirth]).to eq("1990-01-01")
      expect(prosecution_case.defendant[:addressLine1]).to eq("Address Line 1")
      expect(prosecution_case.defendant[:addressLine2]).to eq("Address Line 2")
      expect(prosecution_case.defendant[:addressLine3]).to eq("Address Line 3")
      expect(prosecution_case.defendant[:addressLine4]).to eq("Address Line 4")
      expect(prosecution_case.defendant[:addressLine5]).to eq("Address Line 5")
      expect(prosecution_case.defendant[:postcode]).to eq("SW1 W11")
      expect(prosecution_case.defendant[:nino]).to eq("123456789A")
      expect(prosecution_case.defendant[:email1]).to eq("primary@example.com")
      expect(prosecution_case.defendant[:email2]).to eq("secondary@example.com")
      expect(prosecution_case.defendant[:telephoneHome]).to eq("000-000-0000")
      expect(prosecution_case.defendant[:telephoneMobile]).to eq("222-222-2222")
      expect(prosecution_case.defendant[:telephoneWork]).to eq("111-111-1111")
    end

    it "has the expected offences data" do
      expected_offences = [
        {
          offenceId: "3f153786-f3cf-4311-bc0c-2d6f48af68a1",
          offenceCode: "PT00011",
          asnSeq: 1,
          offenceShortTitle: "Driver / other person fail to immediately move a vehicle from a cordoned area on order of a constable",
          offenceClassification: "5",
          offenceDate: "2019-10-17",
          offenceWording: "Random string",
          modeOfTrial: "Either way",
          legalAidStatus: "AP",
          legalAidStatusDate: "2020-11-05",
          legalAidReason: "FAKE NEWS",
          plea: {
            offenceId: "e58b3a59-e5e5-4ec4-a478-2c846b9e6b6d",
            originatingHearingId: "818d572c-a9e8-4bf2-8eb7-6abf98cd7a5f",
            pleaDate: "2020-04-12",
            pleaValue: "NOT_GUILTY",
          },
          verdict: {
            offenceId: "e58b3a59-e5e5-4ec4-a478-2c846b9e6b6d",
            verdictDate: "2020-04-14",
            category: "verdict type category",
            categoryType: "verdict type category type",
            cjsVerdictCode: "CJS verdict code",
            verdictCode: "verdict code",
          },
          results: [
            {
              laaOfficeAccount: nil,
              legalAidWithdrawalDate: "2020-11-12",
              nextHearingDate: "2020-03-01",
              nextHearingLocation: "B01LY",
              resultCode: "4600",
              resultCodeQualifiers: "qualifier",
              resultShortTitle: "Legal Aid Transfer Granted",
              resultText: "Legal Aid Transfer Granted\nGrant of legal aid transferred to (new firm name) Joe Bloggs Solicitors Ltd, London\nAdditional reasons Defendant's choice\nNew firm's LAA account reference 55558888",
            },
          ],
        },
      ]

      expect(prosecution_case.defendant[:offences]).to eql(expected_offences)
    end
  end

  it "has a session object" do
    expected = {
      courtLocation: "A07AF",
      dateOfHearing: "2019-10-25",
      postHearingCustody: "R",
      sessionValidateDate: "2019-10-25",
    }

    expect(prosecution_case.session).to eql(expected)
  end

  context "when the hearing body has only required fields" do
    let(:hearing) do
      data = JSON.parse(file_fixture("hearing/required_fields.json").read).deep_symbolize_keys
      HmctsCommonPlatform::Hearing.new(data[:hearing])
    end

    let(:defendant) do
      data = JSON.parse(file_fixture("defendant/required_fields.json").read).deep_symbolize_keys
      HmctsCommonPlatform::Defendant.new(data)
    end

    it "has a maat_reference" do
      expect(prosecution_case.maat_reference).to eql("123")
    end

    it "has a case URN" do
      expect(prosecution_case.case_urn).to eq("30DI234234")
    end

    it "has a jurisdiction type" do
      expect(prosecution_case.jurisdiction_type).to eql("CROWN")
    end

    it "has a defendant ASN" do
      expect(prosecution_case.defendant_asn).to be_nil
    end

    it "has a cjs area code" do
      expect(prosecution_case.cjs_area_code).to eql("7")
    end

    it "has a cjs location" do
      expect(prosecution_case.cjs_location).to eql("A07AF")
    end

    it "has a case creation date" do
      expect(prosecution_case.case_creation_date).to eql("2021-03-09")
    end

    it "has a doc language" do
      expect(prosecution_case.doc_language).to be_nil
    end

    it "has proceedings_concluded flag" do
      expect(prosecution_case.proceedings_concluded).to be(false)
    end

    it "has no crown_court_outcome" do
      expect(prosecution_case.crown_court_outcome).to be_nil
    end

    it "is always inactive" do
      expect(prosecution_case.inactive).to eql("Y")
    end

    it "has a function type of PROSECUTION_CASE " do
      expect(prosecution_case.function_type).to eql("PROSECUTION_CASE")
    end

    describe "defendant object" do
      it "has the expected attributes" do
        expect(prosecution_case.defendant[:forename]).to be_nil
        expect(prosecution_case.defendant[:surname]).to be_nil
        expect(prosecution_case.defendant[:dateOfBirth]).to be_nil
        expect(prosecution_case.defendant[:addressLine1]).to be_nil
        expect(prosecution_case.defendant[:addressLine2]).to be_nil
        expect(prosecution_case.defendant[:addressLine3]).to be_nil
        expect(prosecution_case.defendant[:addressLine4]).to be_nil
        expect(prosecution_case.defendant[:addressLine5]).to be_nil
        expect(prosecution_case.defendant[:postcode]).to be_nil
        expect(prosecution_case.defendant[:nino]).to be_nil
        expect(prosecution_case.defendant[:email1]).to be_nil
        expect(prosecution_case.defendant[:email2]).to be_nil
        expect(prosecution_case.defendant[:telephoneHome]).to be_nil
        expect(prosecution_case.defendant[:telephoneMobile]).to be_nil
        expect(prosecution_case.defendant[:telephoneWork]).to be_nil
      end

      it "has the expected offences data" do
        expected_offences = [
          {
            offenceId: "3f153786-f3cf-4311-bc0c-2d6f48af68a1",
            offenceCode: "PT00011",
            asnSeq: 1,
            offenceShortTitle: "Driver / other person fail to immediately move a vehicle from a cordoned area on order of a constable",
            offenceClassification: "5",
            offenceDate: "2019-10-17",
            offenceWording: "Random string",
            modeOfTrial: "Either way",
            legalAidStatus: "AP",
            legalAidStatusDate: "2020-11-05",
            legalAidReason: "FAKE NEWS",
            plea: {
              offenceId: "e58b3a59-e5e5-4ec4-a478-2c846b9e6b6d",
              originatingHearingId: "818d572c-a9e8-4bf2-8eb7-6abf98cd7a5f",
              pleaDate: "2020-04-12",
              pleaValue: "NOT_GUILTY",
            },
            verdict: {
              offenceId: "e58b3a59-e5e5-4ec4-a478-2c846b9e6b6d",
              verdictDate: "2020-04-14",
              category: "verdict type category",
              categoryType: "verdict type category type",
              cjsVerdictCode: "CJS verdict code",
              verdictCode: "verdict code",
            },
            results: [
              {
                laaOfficeAccount: nil,
                legalAidWithdrawalDate: "2020-11-12",
                nextHearingDate: "2020-03-01",
                nextHearingLocation: "B01LY",
                resultCode: "4600",
                resultCodeQualifiers: "qualifier",
                resultShortTitle: "Legal Aid Transfer Granted",
                resultText: "Legal Aid Transfer Granted\nGrant of legal aid transferred to (new firm name) Joe Bloggs Solicitors Ltd, London\nAdditional reasons Defendant's choice\nNew firm's LAA account reference 55558888",
              },
            ],
          },
        ]

        expect(prosecution_case.defendant[:offences]).to eql(expected_offences)
      end
    end
  end
end
