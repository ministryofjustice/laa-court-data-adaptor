class CourtApplication
  attr_reader :hearing, :court_application_data, :maat_reference

  def initialize(hearing_body, court_application_data, maat_reference)
    @shared_time = hearing_body[:sharedTime]
    @hearing = hearing_body[:hearing]
    @court_application_data = court_application_data
    @maat_reference = maat_reference
  end

  def case_urn; end

  def jurisdiction_type
    hearing[:jurisdictionType]
  end

  def defendant_asn
    court_application_data.dig(:applicant, :masterDefendant, :personDefendant, :arrestSummonsNumber)
  end

  def cjs_area_code
    find_court_centre_by_id(hearing[:courtCentre][:id]).oucode_l2_code
  end

  def cjs_location
    court_centre_short_ou_code
  end

  def case_creation_date
    @shared_time.to_date.strftime("%Y-%m-%d")
  end

  def doc_language
    defendant_details&.dig(:documentationLanguageNeeds)
  end

  def proceedings_concluded
    false
  end

  def crown_court_outcome; end

  def inactive
    "Y"
  end

  def function_type
    "APPLICATION"
  end

  def defendant
    {
      forename: defendant_details&.dig(:firstName),
      surname: defendant_details&.dig(:lastName),
      dateOfBirth: defendant_details&.dig(:dateOfBirth),
      addressLine1: defendant_address_details&.dig(:address1),
      addressLine2: defendant_address_details&.dig(:address2),
      addressLine3: defendant_address_details&.dig(:address3),
      addressLine4: defendant_address_details&.dig(:address4),
      addressLine5: defendant_address_details&.dig(:address5),
      postcode: defendant_address_details&.dig(:postcode),
      nino: defendant_details&.dig(:nationalInsuranceNumber),
      telephoneHome: defendant_contact_details&.dig(:home),
      telephoneWork: defendant_contact_details&.dig(:work),
      telephoneMobile: defendant_contact_details&.dig(:mobile),
      email1: defendant_contact_details&.dig(:primaryEmail),
      email2: defendant_contact_details&.dig(:secondaryEmail),
      offences: [offence],
    }
  end

  def session
    {
      courtLocation: court_centre_short_ou_code,
      dateOfHearing: hearing_first_sitting_day_date,
      sessionValidateDate: hearing.dig(:hearingDays, 0, :sittingDay)&.to_date&.strftime("%Y-%m-%d"),
    }
  end

private

  def defendant_details
    master_defendant&.dig(:personDefendant, :personDetails)
  end

  def defendant_address_details
    defendant_details&.dig(:address)
  end

  def defendant_contact_details
    defendant_details&.dig(:contact)
  end

  def master_defendant
    court_application_data.dig(:applicant, :masterDefendant)
  end

  def offence
    {
      offenceId: court_application_type[:id],
      offenceCode: court_application_type[:code],
      offenceShortTitle: court_application_type[:type],
      offenceClassification: court_application_type[:categoryCode],
      offenceDate: court_application_data[:applicationReceivedDate],
      offenceWording: court_application_type[:legislation],
      results: judicial_results,
    }
  end

  def court_application_type
    court_application_data[:type]
  end

  def judicial_results
    court_application_data[:judicialResults]&.map do |judicial_result_data|
      judicial_result = HmctsCommonPlatform::JudicialResult.new(judicial_result_data)

      {
        resultCode: judicial_result.code,
        resultShortTitle: judicial_result.label,
        resultText: judicial_result.text,
        resultCodeQualifiers: judicial_result.qualifier,
        nextHearingDate: judicial_result.next_hearing_date&.to_date&.strftime("%Y-%m-%d"),
        nextHearingLocation: judicial_result.next_hearing_location,
      }
    end
  end

  def court_centre_short_ou_code
    find_court_centre_by_id(hearing[:courtCentre][:id]).short_oucode
  end

  def find_court_centre_by_id(id)
    return if id.blank?

    HmctsCommonPlatform::Reference::CourtCentre.find(id)
  end

  def hearing_first_sitting_day_date
    hearing.dig(:hearingDays, 0, :sittingDay)&.to_date&.strftime("%Y-%m-%d")
  end
end
