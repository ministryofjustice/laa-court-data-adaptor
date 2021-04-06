module MaatApi
  class ProsecutionCase
    attr_reader :hearing, :prosecution_case, :maat_reference
    delegate :jurisdiction_type, to: :hearing

    def initialize(hearing_body, case_urn, defendant_data, maat_reference)
      @shared_time = hearing_body[:sharedTime]
      @case_urn = case_urn
      @hearing = HmctsCommonPlatform::Hearing.new(hearing_body[:hearing])
      @prosecution_case = HmctsCommonPlatform::ProsecutionCase.new(defendant_data)
      @maat_reference = maat_reference
    end

    attr_reader :case_urn

    def defendant_asn
      prosecution_case.defendant_arrest_summons_number
    end

    def cjs_area_code
      court_centre.oucode_l2_code
    end

    def case_creation_date
      @shared_time.to_date.strftime("%Y-%m-%d")
    end

    def cjs_location
      court_centre.short_oucode
    end

    def doc_language
      # Should we derive this from somewhere else?
      "EN"
    end

    def proceedings_concluded
      prosecution_case.proceedings_concluded || false
    end

    def inactive
      jurisdiction_type == "MAGISTRATES" ? "N" : "Y"
    end

    def function_type
      "OFFENCE"
    end

    def defendant
      {
        forename: prosecution_case.defendant_first_name,
        surname: prosecution_case.defendant_last_name,
        dateOfBirth: prosecution_case.defendant_date_of_birth,
        addressLine1: prosecution_case.defendant_address_1,
        addressLine2: prosecution_case.defendant_address_2,
        addressLine3: prosecution_case.defendant_address_3,
        addressLine4: prosecution_case.defendant_address_4,
        addressLine5: prosecution_case.defendant_address_5,
        postcode: prosecution_case.defendant_postcode,
        nino: prosecution_case.defendant_nino,
        telephoneHome: prosecution_case.defendant_phone_home,
        telephoneWork: prosecution_case.defendant_phone_work,
        telephoneMobile: prosecution_case.defendant_phone_mobile,
        email1: prosecution_case.defendant_email_primary,
        email2: prosecution_case.defendant_email_secondary,
        offences: offences,
      }
    end

    def session
      {
        courtLocation: court_centre.short_oucode,
        dateOfHearing: prosecution_case&.offences&.first&.results&.first&.ordered_date,
        postHearingCustody: PostHearingCustodyCalculator.call(offences: offences),
        sessionValidateDate: prosecution_case&.offences&.first&.results&.first&.ordered_date,
      }
    end

    def crown_court_outcome; end

  private

    def offences
      prosecution_case.offences&.map do |offence|
        {
          offenceId: offence.id,
          offenceCode: offence.offence_code,
          asnSeq: offence.order_index,
          offenceShortTitle: offence.offence_title,
          offenceClassification: offence.mode_of_trial,
          offenceDate: offence.start_date,
          offenceWording: offence.wording,
          modeOfTrial: offence.allocation_decision_mot_reason_code,
          legalAidStatus: offence.laa_appln_reference_status_code,
          legalAidStatusDate: offence.laa_appln_reference_status_date,
          legalAidReason: offence.laa_appln_reference_status_description,
          results: judicial_results(offence),
          plea: plea(offence.plea),
          verdict: verdict(offence),
        }
      end
    end

    def judicial_results(offence)
      offence.results&.map do |judicial_result|
        {
          resultCode: judicial_result.code,
          resultShortTitle: judicial_result.label,
          resultText: judicial_result.text,
          resultCodeQualifiers: judicial_result.qualifier,
          nextHearingDate: judicial_result.next_hearing_date&.to_date&.strftime("%Y-%m-%d"),
          nextHearingLocation: find_court_centre_by_id(judicial_result.next_hearing_court_centre_id)&.short_oucode,
          laaOfficeAccount: offence.laa_appln_reference_laa_contract_number,
          legalAidWithdrawalDate: offence.laa_appln_reference_end_date,
        }
      end
    end

    def plea(data)
      return if data.nil?

      {
        originatingHearingId: data.originating_hearing_id,
        delegatedPowers: delegated_powers(data.delegated_powers),
        offenceId: data.offence_id,
        applicationId: data.application_id,
        pleaDate: data.plea_date,
        pleaValue: data.plea_date,
        lesserOrAlternativeOffence: lesser_or_alternative_offence(data.lesser_or_alternative_offence),
      }
    end

    def delegated_powers(data)
      {
        userId: data.user_id,
        firstName: data.first_name,
        lastName: data.last_name,
      }
    end

    def lesser_or_alternative_offence(data)
      {
        offenceDefinitionId: data.offence_definition_id,
        offenceCode: data.offence_code,
        offenceTitle: data.offence_title,
        offenceTitleWelsh: data.offence_title_welsh,
        offenceLegislation: data.offence_legislation,
        offenceLegislationWelsh: data.offence_legislation_welsh,
      }
    end

    def verdict(offence)
      return if offence.nil?

      {
        offenceId: offence.verdict_offence_id,
        verdictDate: offence.verdict_date,
        category: offence.verdict_type_category,
        categoryType: offence.verdict_type_category_type,
        cjsVerdictCode: offence.verdict_type_cjs_verdict_code,
        verdictCode: offence.verdict_type_verdict_code,
      }
    end

    def court_centre
      find_court_centre_by_id(hearing.court_centre_id)
    end

    def find_court_centre_by_id(id)
      return if id.blank?

      HmctsCommonPlatform::Reference::CourtCentre.find(id)
    end
  end
end
