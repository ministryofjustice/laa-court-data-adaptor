module MaatApi
  class CourtApplication
    attr_reader :hearing_resulted, :court_application, :maat_reference

    def initialize(hearing_resulted, court_application, maat_reference)
      @hearing_resulted = hearing_resulted
      @court_application = court_application
      @maat_reference = maat_reference
    end

    def hearing_id
      hearing_resulted.hearing.id
    end

    def case_urn; end

    def defendant_asn
      court_application.defendant_arrest_summons_number
    end

    def cjs_area_code
      hearing_resulted.hearing_court_centre.oucode_l2_code
    end

    def cjs_location
      hearing_resulted.hearing_court_centre.short_oucode
    end

    def case_creation_date
      hearing_resulted.shared_time.to_date.strftime("%Y-%m-%d")
    end

    def doc_language
      court_application.defendant_documentation_language_needs
    end

    def proceedings_concluded
      false
    end

    def inactive
      "Y"
    end

    def function_type
      "APPLICATION"
    end

    def jurisdiction_type
      hearing_resulted.hearing_jurisdiction_type
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
        courtLocation: hearing_resulted.hearing_court_centre.short_oucode,
        dateOfHearing: hearing_first_sitting_day_date,
        sessionValidateDate: hearing_first_sitting_day_date,
      }
    end

  private

    def offence
      {
        offenceId: court_application.type_id,
        offenceCode: court_application.type_code,
        offenceShortTitle: court_application.type_description,
        offenceClassification: court_application.type_category_code,
        offenceDate: court_application.received_date,
        offenceWording: offence_wording,
        results: judicial_results,
      }
    end

    def judicial_results
      court_application.judicial_results&.map do |judicial_result|
        {
          resultCode: judicial_result.cjs_code,
          resultShortTitle: judicial_result.label,
          resultText: judicial_result.text,
          category: judicial_result.category,
          resultCodeQualifiers: judicial_result.qualifier,
          nextHearingDate: judicial_result.next_hearing_date&.to_date&.strftime("%Y-%m-%d"),
          nextHearingLocation: judicial_result.next_hearing_court_centre&.short_oucode,
          isConvictedResult: judicial_result.is_convicted_result,
        }
      end
    end

    def offence_wording
      [court_application.application_particulars, court_application.type_legislation].compact.join(" - ").presence
    end

    def hearing_first_sitting_day_date
      hearing_resulted.hearing_first_sitting_day_date&.to_date&.strftime("%Y-%m-%d")
    end
  end
end
