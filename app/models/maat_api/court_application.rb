module MaatApi
  class CourtApplication
    attr_reader :hearing, :court_application, :maat_reference
    delegate :jurisdiction_type, to: :hearing

    def initialize(hearing_body, court_application_data, maat_reference)
      @shared_time = hearing_body[:sharedTime]
      @hearing = HmctsCommonPlatform::Hearing.new(hearing_body[:hearing])
      @court_application = HmctsCommonPlatform::CourtApplication.new(court_application_data)
      @maat_reference = maat_reference
    end

    def case_urn; end

    def defendant_asn
      court_application.defendant_arrest_summons_number
    end

    def cjs_area_code
      find_court_centre_by_id(hearing.court_centre_id).oucode_l2_code
    end

    def cjs_location
      court_centre_short_ou_code
    end

    def case_creation_date
      @shared_time.to_date.strftime("%Y-%m-%d")
    end

    def doc_language
      court_application.defendant_documentation_language_needs
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
        forename: court_application.defendant_first_name,
        surname: court_application.defendant_last_name,
        dateOfBirth: court_application.defendant_date_of_birth,
        addressLine1: court_application.defendant_address_1,
        addressLine2: court_application.defendant_address_2,
        addressLine3: court_application.defendant_address_3,
        addressLine4: court_application.defendant_address_4,
        addressLine5: court_application.defendant_address_5,
        postcode: court_application.defendant_postcode,
        nino: court_application.defendant_nino,
        telephoneHome: court_application.defendant_phone_home,
        telephoneWork: court_application.defendant_phone_work,
        telephoneMobile: court_application.defendant_phone_mobile,
        email1: court_application.defendant_email_primary,
        email2: court_application.defendant_email_secondary,
        offences: [offence],
      }
    end

    def session
      {
        courtLocation: court_centre_short_ou_code,
        dateOfHearing: hearing_first_sitting_day_date,
        sessionValidateDate: hearing_first_sitting_day_date,
      }
    end

  private

    def offence
      {
        offenceId: court_application.type_id,
        offenceCode: court_application.type_code,
        offenceShortTitle: court_application.type_name,
        offenceClassification: court_application.type_category_code,
        offenceDate: court_application.received_date,
        offenceWording: court_application.type_legislation,
        results: judicial_results,
      }
    end

    def judicial_results
      court_application.judicial_results&.map do |judicial_result|
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
      find_court_centre_by_id(hearing.court_centre_id).short_oucode
    end

    def hearing_first_sitting_day_date
      hearing.first_sitting_day_date&.to_date&.strftime("%Y-%m-%d")
    end

    def find_court_centre_by_id(id)
      return if id.blank?

      HmctsCommonPlatform::Reference::CourtCentre.find(id)
    end
  end
end
