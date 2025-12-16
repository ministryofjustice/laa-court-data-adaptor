module MaatApi
  class CourtApplicationLaaReference
    include HearingSummarySelectable

    attr_reader :court_application_summary, :user_name, :maat_reference

    delegate :subject_summary, :case_summary, to: :court_application_summary
    delegate :defendant_asn, to: :subject_summary

    def initialize(user_name:, maat_reference:, court_application_summary:)
      @maat_reference = maat_reference
      @user_name = user_name
      @court_application_summary = court_application_summary
    end

    def case_urn
      court_application_summary.short_id
    end

    def doc_language
      "EN"
    end

    def is_active?
      # Defaults to true if no case summary is present
      return true if case_summary.blank?

      case_summary.first.case_status == "ACTIVE"
    end

    def cjs_location
      relevant_hearing_summary.court_centre_short_oucode
    end

    def cjs_area_code
      relevant_hearing_summary.court_centre_oucode_l2_code
    end

    def defendant
      {
        defendantId: subject_summary.subject_id,
        forename: subject_summary.defendant_first_name,
        surname: subject_summary.defendant_last_name,
        dateOfBirth: subject_summary.defendant_dob,
        nino: subject_summary.defendant_nino,
        offences:,
      }
    end

    def sessions
      hearing_summaries.map do |hearing_summary|
        {
          courtLocation: hearing_summary.court_centre_short_oucode,
          dateOfHearing: hearing_summary.hearing_days.map(&:sitting_day).max&.to_date&.strftime("%Y-%m-%d"),
        }
      end
    end

  private

    def hearing_summaries
      court_application_summary.hearing_summary
    end

    def offences
      subject_summary.offence_summary.map do |offence_summary|
        {
          offenceId: offence_summary.offence_id,
          offenceCode: offence_summary.code,
          asnSeq: offence_summary.order_index,
          offenceClassification: offence_summary.mode_of_trial,
          offenceDate: offence_summary.start_date,
          offenceShortTitle: offence_summary.title,
          offenceWording: offence_summary.wording,
        }
      end
    end
  end
end
