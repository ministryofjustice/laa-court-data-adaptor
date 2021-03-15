# frozen_string_literal: true

RSpec.describe MaatApi::Message do
  let(:expected_payload) do
    {
      maatId: "maat reference",
      caseUrn: "case urn",
      jurisdictionType: "jurisdiction type",
      asn: "asn",
      cjsAreaCode: "cjs area code",
      caseCreationDate: "2018-10-25",
      cjsLocation: "cjs location",
      docLanguage: "EN",
      proceedingsConcluded: "proceedings concluded flag",
      inActive: "Y",
      function_type: "function type",
      defendant: "defendant",
      session: "session",
      ccOutComeData: "crown court outcome data",
    }
  end

  it "builds a MAAT API payload hash from a compatible object" do
    maat_api_messageable = Messageable.new
    message = described_class.new(maat_api_messageable).generate

    expect(message).to eql(expected_payload)
  end
end

class Messageable
  def maat_reference
    "maat reference"
  end

  def case_urn
    "case urn"
  end

  def jurisdiction_type
    "jurisdiction type"
  end

  def defendant_asn
    "asn"
  end

  def cjs_area_code
    "cjs area code"
  end

  def cjs_location
    "cjs location"
  end

  def case_creation_date
    "2018-10-25"
  end

  def doc_language
    "EN"
  end

  def proceedings_concluded
    "proceedings concluded flag"
  end

  def inactive
    "Y"
  end

  def function_type
    "function type"
  end

  def crown_court_outcome
    "crown court outcome data"
  end

  def defendant
    "defendant"
  end

  def session
    "session"
  end
end
