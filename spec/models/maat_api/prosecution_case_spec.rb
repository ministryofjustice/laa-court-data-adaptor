RSpec.describe MaatApi::ProsecutionCase, type: :model do
  let(:maat_reference) { "123" }
  let(:prosecution_case_data) { hearing_resulted_data.dig(:hearing, :prosecutionCases).first }
  let(:case_urn) { prosecution_case_data[:prosecutionCaseIdentifier][:caseURN] }
  let(:defendant_data) { prosecution_case_data[:defendants].first }

  let(:prosecution_case) do
    described_class.new(
      HmctsCommonPlatform::HearingResulted.new(hearing_resulted_data),
      case_urn,
      HmctsCommonPlatform::Defendant.new(defendant_data),
      maat_reference,
    )
  end

  context "when prosecution case has all fields" do
    let(:hearing_resulted_data) { JSON.parse(file_fixture("hearing/with_prosecution_case.json").read).deep_symbolize_keys }

    it "has a hearing ID" do
      expect(prosecution_case.hearing_id).to eql("b935a64a-6d03-4da4-bba6-4d32cc2e7fb4")
    end

    it "has a maat_reference" do
      expect(prosecution_case.maat_reference).to eql("123")
    end

    it "has a case URN" do
      expect(prosecution_case.case_urn).to eql("20GD0217100")
    end

    it "has a jurisdiction type" do
      expect(prosecution_case.jurisdiction_type).to eql("CROWN")
    end

    it "has a defendant ASN" do
      expect(prosecution_case.defendant_asn).to eql("XVITYX8RAIHZ")
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
      expect(prosecution_case.doc_language).to eql("EN")
    end

    it "has a proceedings_concluded flag" do
      expect(prosecution_case.proceedings_concluded).to be(false)
    end

    it "has a crown_court_outcome" do
      expected = "Crown Court Outcome"

      allow(CrownCourtOutcomeCreator).to receive(:call).and_return(expected)

      expect(prosecution_case.crown_court_outcome).to eql(expected)
    end

    it "has an inactive" do
      expect(prosecution_case.inactive).to eql("Y")
    end

    it "has a function type of OFFENCE" do
      expect(prosecution_case.function_type).to eql("OFFENCE")
    end

    it "has a defendant object" do
      expected = {
        forename: "Jammy",
        surname: "Dodger",
        dateOfBirth: "1987-05-21",
        addressLine1: "6376 Merrilee Loop",
        addressLine2: "Suite 304",
        addressLine3: "28301",
        addressLine4: "Cinthiatown",
        addressLine5: "Kyrgyz Republic",
        postcode: "35848-9420",
        nino: "JC123456A",
        telephoneHome: "02070000000",
        telephoneMobile: "07000000000",
        telephoneWork: "02070000001",
        email1: "primary@example.com",
        email2: "secondary@example.com",
        offences: [
          {
            offenceId: "3f153786-f3cf-4311-bc0c-2d6f48af68a1",
            offenceCode: "LA12505",
            asnSeq: 1,
            offenceShortTitle: "Driver / other person fail to immediately move a vehicle from a cordoned area on order of a constable",
            offenceClassification: "Either way",
            offenceDate: "2019-10-17",
            offenceWording: "Random string",
            modeOfTrial: "5",
            legalAidStatus: "AP",
            legalAidStatusDate: "2020-11-05",
            legalAidReason: "FAKE NEWS",
            results: [
              {
                resultCode: "4600",
                resultShortTitle: "Found guilty on all charges",
                resultText: "Result",
                category: "A",
                resultCodeQualifiers: "Qualifier",
                nextHearingDate: "2019-10-23",
                nextHearingLocation: "B21JI",
                laaOfficeAccount: "092874",
                legalAidWithdrawalDate: "2021-04-11",
              },
            ],
            plea: {
              applicationId: "b71b3a59-82sx-8ebz-a478-bb846b9kd8s6",
              delegatedPowers: {
                firstName: "Ada",
                lastName: "Lovelace",
                userId: "sd22b110-0pbc-3136-a076-e4bb40d0a986",
              },
              lesserOrAlternativeOffence: {
                offenceCode: "1245",
                offenceDefinitionId: "o18d572c-3aa3-a076-82sx-ba3afb7ff94a",
                offenceLegislation: "Common Law",
                offenceLegislationWelsh: "Cyfraith Gwlad",
                offenceTitle: "Disorderly conduct",
                offenceTitleWelsh: "Ymddygiad afreolus",
              },
              offenceId: "e58b3a59-e5e5-4ec4-a478-2c846b9e6b6d",
              originatingHearingId: "818d572c-a9e8-4bf2-8eb7-6abf98cd7a5f",
              pleaDate: "2020-04-12",
              pleaValue: "NOT_GUILTY",
            },
            verdict: {
              offenceId: "3f153786-f3cf-4311-bc0c-2d6f48af68a1",
              verdictDate: "2021-04-10",
              category: "A",
              categoryType: "GUILTY",
              cjsVerdictCode: "1093",
              verdictCode: "367A",
            },
          },
        ],
      }

      expect(prosecution_case.defendant).to eql(expected)
    end

    it "has a session object" do
      allow(PostHearingCustodyCalculator).to receive(:call).and_return("B")

      expected = {
        courtLocation: "A07AF",
        dateOfHearing: "2021-03-10",
        postHearingCustody: "B",
        sessionValidateDate: "2021-03-10",
      }

      expect(prosecution_case.session).to eql(expected)
    end
  end

  context "when the hearing body has only required fields" do
    let(:hearing_resulted_data) { JSON.parse(file_fixture("hearing/with_prosecution_case_required_only.json").read).deep_symbolize_keys }

    it "has a hearing ID" do
      expect(prosecution_case.hearing_id).to eql("b935a64a-6d03-4da4-bba6-4d32cc2e7fb4")
    end

    it "has a maat_reference" do
      expect(prosecution_case.maat_reference).to eql("123")
    end

    it "has a case URN" do
      expect(prosecution_case.case_urn).to eql("20GD0217100")
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
      expect(prosecution_case.doc_language).to eql("EN")
    end

    it "defaults proceedings_concluded to false" do
      expect(prosecution_case.proceedings_concluded).to be(false)
    end

    it "has no crown_court_outcome" do
      allow(CrownCourtOutcomeCreator).to receive(:call).and_return(nil)

      expect(prosecution_case.crown_court_outcome).to be_nil
    end

    it "has an inactive" do
      expect(prosecution_case.inactive).to eql("Y")
    end

    it "has a function type of OFFENCE" do
      expect(prosecution_case.function_type).to eql("OFFENCE")
    end

    it "has a defendant object" do
      expected = {
        forename: nil,
        surname: nil,
        dateOfBirth: nil,
        addressLine1: nil,
        addressLine2: nil,
        addressLine3: nil,
        addressLine4: nil,
        addressLine5: nil,
        postcode: nil,
        nino: nil,
        telephoneHome: nil,
        telephoneMobile: nil,
        telephoneWork: nil,
        email1: nil,
        email2: nil,
        offences: [
          {
            offenceId: "3f153786-f3cf-4311-bc0c-2d6f48af68a1",
            offenceCode: "PT00011",
            asnSeq: nil,
            offenceShortTitle: "Driver / other person fail to immediately move a vehicle from a cordoned area on order of a constable",
            offenceClassification: nil,
            offenceDate: "2019-10-17",
            offenceWording: "Random string",
            modeOfTrial: nil,
            legalAidStatus: nil,
            legalAidStatusDate: nil,
            legalAidReason: nil,
            results: [],
            plea: {
              delegatedPowers: {},
              lesserOrAlternativeOffence: {},
            },
            verdict: {},
          },
        ],
      }

      expect(prosecution_case.defendant).to eql(expected)
    end

    it "has a session object" do
      allow(PostHearingCustodyCalculator).to receive(:call).and_return("A")

      expected = {
        courtLocation: "A07AF",
        dateOfHearing: nil,
        postHearingCustody: "A",
        sessionValidateDate: nil,
      }

      expect(prosecution_case.session).to eql(expected)
    end
  end
end
