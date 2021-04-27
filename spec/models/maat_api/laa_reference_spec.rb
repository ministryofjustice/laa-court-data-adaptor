RSpec.describe MaatApi::LaaReference, type: :model do
  let(:prosecution_case_summary_data) { JSON.parse(file_fixture("prosecution_case_summary/all_fields.json").read) }
  let(:prosecution_case_summary) { HmctsCommonPlatform::ProsecutionCaseSummary.new(prosecution_case_summary_data) }
  let(:maat_reference) { "123" }
  let(:defendant_summary) { prosecution_case_summary.defendant_summaries.first }
  let(:user_name) { "test-user" }

  let(:laa_reference) do
    described_class.new(
      prosecution_case_summary: prosecution_case_summary,
      defendant_summary: defendant_summary,
      user_name: user_name,
      maat_reference: maat_reference,
    )
  end

  it "has a maat_reference" do
    expect(laa_reference.maat_reference).to eql("123")
  end

  it "has a prosecution case URN" do
    expect(laa_reference.case_urn).to eql("30DI0570888")
  end

  it "has a defendant ASN" do
    expect(laa_reference.defendant_asn).to eql("2100000000000267128K")
  end

  it "has a cjs area code" do
    expect(laa_reference.cjs_area_code).to eql("30")
  end

  it "has a cjs location" do
    expect(laa_reference.cjs_location).to eql("B30PI")
  end

  it "has a user name" do
    expect(laa_reference.user_name).to eql("test-user")
  end

  it "has a doc language" do
    expect(laa_reference.doc_language).to eql("EN")
  end

  it "has an isActive flag" do
    expect(laa_reference.is_active?).to be true
  end

  it "has a defendant payload" do
    expected = {
      dateOfBirth: "1986-11-10",
      defendantId: "b760daba-0d38-4bae-ad57-fbfd8419aefe",
      forename: "Bob",
      nino: "SJ12345678",
      surname: "Smith",
      offences: [
        {
          asnSeq: 1,
          offenceClassification: "Indictable",
          offenceCode: "TH68026C",
          offenceDate: "2021-03-06",
          offenceId: "9aca847f-da4e-444b-8f5a-2ce7d776ab75",
          offenceShortTitle: "Conspire to commit a burglary dwelling with intent to steal",
          offenceWording: "In the county of DERBYSHIRE, conspired together with John Doe to enter as a trespasser",
        },
        {
          asnSeq: 2,
          offenceClassification: "Either Way",
          offenceCode: "CJ88149",
          offenceDate: "2021-03-23",
          offenceId: "4a852bd1-0068-422c-994f-78a5373ecd75",
          offenceShortTitle: "Assault by beating of an emergency worker",
          offenceWording: "On 23.05.2021 at DERBY in the county of DERBYSHIRE assaulted an emergency worker, namely Police Constable",
        },
      ],
    }

    expect(laa_reference.defendant).to eql(expected)
  end

  it "has a sessions payload" do
    expected = [
      {
        courtLocation: "B30PI",
        dateOfHearing: "2021-03-25",
      },
      {
        courtLocation: "C30DE",
        dateOfHearing: "2021-05-20",
      },
    ]

    expect(laa_reference.sessions).to eql(expected)
  end
end
