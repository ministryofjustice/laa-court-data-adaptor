module MaatApi
  class LaaReference
    attr_reader :prosecution_case_summary, :defendant_summary, :user_name, :maat_reference

    def initialize(prosecution_case_summary:, defendant_summary:, user_name:, maat_reference:)
      @prosecution_case_summary = prosecution_case_summary
      @maat_reference = maat_reference
      @defendant_summary = defendant_summary
      @user_name = user_name
    end

    def case_urn
      prosecution_case_summary.prosecution_case_reference
    end

    def defendant_asn
      defendant_summary.arrest_summons_number
    end

    def doc_language
      "EN"
    end

    def is_active?
      prosecution_case_summary.case_status == "ACTIVE"
    end

    def cjs_location
      nearest_in_time_hearing_summary.short_oucode
    end

    def cjs_area_code
      nearest_in_time_hearing_summary.oucode_l2_code
    end

    def defendant
      {
        defendantId: defendant_summary.defendant_id,
        forename: defendant_summary.first_name,
        surname: defendant_summary.last_name,
        dateOfBirth: defendant_summary.date_of_birth,
        nino: defendant_summary.national_insurance_number,
        offences: offences_map,
      }
    end

    def sessions
      prosecution_case_summary.hearing_summaries.map do |hearing_summary|
        {
          courtLocation: hearing_summary.short_oucode,
          dateOfHearing: hearing_summary.date_of_hearing&.strftime("%Y-%m-%d"),
        }
      end
    end

  private

    def nearest_in_time_hearing_summary
      return hearing_summaries_with_hearing_days.max_by(&:hearing_days) if all_hearings_in_past?
      return hearing_summaries_with_hearing_days.min_by(&:hearing_days) if all_hearings_in_future?

      hearing_summaries_with_hearing_days.reject(&:hearing_in_future?).max_by(&:hearing_days)
    end

    def hearing_summaries_with_hearing_days
      prosecution_case_summary.hearing_summaries.reject { |summary| summary.hearing_days.blank? }
    end

    def all_hearings_in_past?
      hearing_summaries_with_hearing_days.all? do |hearing_summary|
        hearing_summary.hearing_days.max&.to_date.past?
      end
    end

    def all_hearings_in_future?
      hearing_summaries_with_hearing_days.all? do |hearing_summary|
        hearing_summary.hearing_days.max&.to_date.future?
      end
    end

    def offences_map
      defendant_summary.offence_summaries.map do |offence_summary|
        {
          offenceId: offence_summary.offence_id,
          offenceCode: offence_summary.offence_code,
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
