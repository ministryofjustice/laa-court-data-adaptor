module MaatApi
  class ProsecutionCase
    attr_reader :hearing, :hmcts_common_platform_defendant, :maat_reference
    delegate :jurisdiction_type, to: :hearing

    def initialize(hearing_body, case_urn, defendant_data, maat_reference)
      @shared_time = hearing_body[:sharedTime]
      @case_urn = case_urn
      @hearing = HmctsCommonPlatform::Hearing.new(hearing_body[:hearing])
      @defendant_data = defendant_data
      @hmcts_common_platform_defendant = HmctsCommonPlatform::Defendant.new(defendant_data)
      @maat_reference = maat_reference
    end

    attr_reader :case_urn

    def defendant_asn
      hmcts_common_platform_defendant.arrest_summons_number
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
      "EN"
    end

    def proceedings_concluded
      hmcts_common_platform_defendant.proceedings_concluded || false
    end

    def inactive
      jurisdiction_type == "MAGISTRATES" ? "N" : "Y"
    end

    def function_type
      "OFFENCE"
    end

    def defendant
      {
        forename: hmcts_common_platform_defendant.first_name,
        surname: hmcts_common_platform_defendant.last_name,
        dateOfBirth: hmcts_common_platform_defendant.date_of_birth,
        addressLine1: hmcts_common_platform_defendant.address_1,
        addressLine2: hmcts_common_platform_defendant.address_2,
        addressLine3: hmcts_common_platform_defendant.address_3,
        addressLine4: hmcts_common_platform_defendant.address_4,
        addressLine5: hmcts_common_platform_defendant.address_5,
        postcode: hmcts_common_platform_defendant.postcode,
        nino: hmcts_common_platform_defendant.nino,
        telephoneHome: hmcts_common_platform_defendant.phone_home,
        telephoneWork: hmcts_common_platform_defendant.phone_work,
        telephoneMobile: hmcts_common_platform_defendant.phone_mobile,
        email1: hmcts_common_platform_defendant.email_primary,
        email2: hmcts_common_platform_defendant.email_secondary,
        offences: offences,
      }
    end

    def session
      {
        courtLocation: court_centre.short_oucode,
        dateOfHearing: hmcts_common_platform_defendant.offences&.first&.results&.first&.ordered_date,
        postHearingCustody: PostHearingCustodyCalculator.call(offences: @defendant_data[:offences]),
        sessionValidateDate: hmcts_common_platform_defendant.offences&.first&.results&.first&.ordered_date,
      }
    end

    def crown_court_outcome
      CrownCourtOutcomeCreator.call(defendant: @defendant_data, appeal_data: nil) if jurisdiction_type == "CROWN" && result_is_a_conclusion?
    end

  private

    def offences
      hmcts_common_platform_defendant.offences.map do |offence|
        {
          offenceId: offence.id,
          offenceCode: offence.offence_code,
          asnSeq: offence.order_index,
          offenceShortTitle: offence.offence_title,
          offenceClassification: offence.mode_of_trial,
          offenceDate: offence.start_date,
          offenceWording: offence.wording,
          modeOfTrial: offence.allocation_decision_mot_reason_code,
          legalAidStatus: offence.laa_reference_status_code,
          legalAidStatusDate: offence.laa_reference_status_date,
          legalAidReason: offence.laa_reference_status_description,
          results: judicial_results(offence),
          plea: plea(offence.plea),
          verdict: verdict(offence.verdict),
        }
      end
    end

    def judicial_results(offence)
      offence.results&.map do |judicial_result|
        {
          resultCode: judicial_result.cjs_code,
          resultShortTitle: judicial_result.label,
          resultText: judicial_result.text,
          resultCodeQualifiers: judicial_result.qualifier,
          nextHearingDate: judicial_result.next_hearing_date&.to_date&.strftime("%Y-%m-%d"),
          nextHearingLocation: find_court_centre_by_id(judicial_result.next_hearing_court_centre_id)&.short_oucode,
          laaOfficeAccount: offence.laa_reference_laa_contract_number,
          legalAidWithdrawalDate: offence.laa_reference_effective_end_date,
        }
      end
    end

    def plea(data)
      {
        originatingHearingId: data.originating_hearing_id,
        delegatedPowers: delegated_powers(data.delegated_powers),
        offenceId: data.offence_id,
        applicationId: data.application_id,
        pleaDate: data.plea_date,
        pleaValue: data.plea_value,
        lesserOrAlternativeOffence: lesser_or_alternative_offence(data.lesser_or_alternative_offence),
      }.compact
    end

    def verdict(data)
      {
        offenceId: data.offence_id,
        verdictDate: data.verdict_date,
        category: data.verdict_type_category,
        categoryType: data.verdict_type_category_type,
        cjsVerdictCode: data.verdict_type_cjs_verdict_code,
        verdictCode: data.verdict_type_verdict_code,
      }.compact
    end

    def delegated_powers(data)
      {
        userId: data.user_id,
        firstName: data.first_name,
        lastName: data.last_name,
      }.compact
    end

    def lesser_or_alternative_offence(data)
      {
        offenceDefinitionId: data.offence_definition_id,
        offenceCode: data.offence_code,
        offenceTitle: data.offence_title,
        offenceTitleWelsh: data.offence_title_welsh,
        offenceLegislation: data.offence_legislation,
        offenceLegislationWelsh: data.offence_legislation_welsh,
      }.compact
    end

    def court_centre
      find_court_centre_by_id(hearing.court_centre_id)
    end

    def find_court_centre_by_id(id)
      return if id.blank?

      HmctsCommonPlatform::Reference::CourtCentre.find(id)
    end

    def result_is_a_conclusion?
      @defendant_data[:offences]&.any? { |offence| offence[:verdict].present? }
    end
  end
end
