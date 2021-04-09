module MaatApi
  class ProsecutionCase
    attr_reader :hearing, :hmcts_defendant, :maat_reference, :case_urn

    delegate :jurisdiction_type, to: :hearing
    delegate :proceedings_concluded, to: :hmcts_defendant

    def initialize(shared_time, maat_reference, case_urn, hearing, hmcts_defendant)
      @shared_time = shared_time
      @maat_reference = maat_reference
      @case_urn = case_urn
      @hearing = hearing
      @hmcts_defendant = hmcts_defendant
    end

    def defendant_asn
      hmcts_defendant.arrest_summons_number
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
      hmcts_defendant.documentation_language_needs
    end

    def crown_court_outcome; end

    def inactive
      jurisdiction_type == "MAGISTRATES" ? "N" : "Y"
    end

    def function_type
      "PROSECUTION_CASE"
    end

    def defendant
      {
        forename: hmcts_defendant.first_name,
        surname: hmcts_defendant.last_name,
        dateOfBirth: hmcts_defendant.date_of_birth,
        addressLine1: hmcts_defendant.address_1,
        addressLine2: hmcts_defendant.address_2,
        addressLine3: hmcts_defendant.address_3,
        addressLine4: hmcts_defendant.address_4,
        addressLine5: hmcts_defendant.address_5,
        postcode: hmcts_defendant.postcode,
        nino: hmcts_defendant.nino,
        telephoneHome: hmcts_defendant.phone_home,
        telephoneWork: hmcts_defendant.phone_work,
        telephoneMobile: hmcts_defendant.phone_mobile,
        email1: hmcts_defendant.email_primary,
        email2: hmcts_defendant.email_secondary,
        offences: offences,
      }
    end

    def session
      {
        courtLocation: court_centre_short_ou_code,
        dateOfHearing: hearing_first_sitting_day_date,
        postHearingCustody: PostHearingCustodyCalculator.call(offences: hmcts_defendant.offences.map(&:data)),
        sessionValidateDate: hearing_first_sitting_day_date,
      }
    end

  private

    def offences
      hmcts_defendant.offences.map do |offence|
        {
          offenceId: offence.id,
          offenceCode: offence.code,
          asnSeq: offence.order_index,
          offenceShortTitle: offence.title,
          offenceClassification: offence.allocation_decision_mot_reason_code,
          offenceDate: offence.start_date,
          offenceWording: offence.wording,
          modeOfTrial: offence.mode_of_trial,
          legalAidStatus: offence.laa_reference_status_code,
          legalAidStatusDate: offence.laa_reference_status_date,
          legalAidReason: offence.laa_reference_status_description,
          plea: offence.plea,
          verdict: format_verdict(offence.verdict),
          results: judicial_results(offence),
        }
      end
    end

    def format_verdict(verdict)
      return if verdict.nil?

      {
        offenceId: verdict.offence_id,
        verdictDate: verdict.date,
        category: verdict.type_category,
        categoryType: verdict.type_category_type,
        cjsVerdictCode: verdict.type_cjs_code,
        verdictCode: verdict.type_code,
      }
    end

    def judicial_results(offence)
      offence.judicial_results&.map do |judicial_result|
        {
          resultCode: judicial_result.code,
          resultShortTitle: judicial_result.label,
          resultText: judicial_result.text,
          resultCodeQualifiers: judicial_result.qualifier,
          nextHearingDate: judicial_result.next_hearing_date&.to_date&.strftime("%Y-%m-%d"),
          nextHearingLocation: find_court_centre_by_id(judicial_result.next_hearing_court_centre_id)&.short_oucode,
          laaOfficeAccount: hmcts_defendant.defence_organisation_laa_account_number,
          legalAidWithdrawalDate: offence.laa_reference_effective_end_date,
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
