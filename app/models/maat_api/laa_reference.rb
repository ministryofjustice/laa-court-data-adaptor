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
      relevant_hearing_summary.court_centre_short_oucode
    end

    def cjs_area_code
      relevant_hearing_summary.court_centre_oucode_l2_code
    end

    def defendant
      {
        defendantId: defendant_summary.defendant_id,
        forename: defendant_summary.first_name,
        surname: defendant_summary.last_name,
        dateOfBirth: defendant_summary.date_of_birth,
        nino: defendant_summary.national_insurance_number,
        offences:,
      }
    end

    def sessions
      prosecution_case_summary.hearing_summaries.map do |hearing_summary|
        {
          courtLocation: hearing_summary.court_centre_short_oucode,
          dateOfHearing: hearing_summary.hearing_days.map(&:sitting_day).max&.to_date&.strftime("%Y-%m-%d"),
        }
      end
    end

  private

    def relevant_hearing_summary
      return latest_hearing_summary if all_hearings_in_past?
      return next_upcoming_hearing_summary if all_hearings_in_future?

      latest_of_past_hearing_summaries
    end

    def latest_of_past_hearing_summaries
      past_hearing_summaries.max_by { |hs| hs.hearing_days.map(&:sitting_day) }
    end

    def next_upcoming_hearing_summary
      hearing_summaries_with_hearing_days.min_by { |hs| hs.hearing_days.map(&:sitting_day) }
    end

    def latest_hearing_summary
      hearing_summaries_with_hearing_days.max_by { |hs| hs.hearing_days.map(&:sitting_day) }
    end

    def past_hearing_summaries
      hearing_summaries_with_hearing_days.select do |hs|
        hs.hearing_days.map(&:sitting_day).max&.in_time_zone&.past?
      end
    end

    def all_hearings_in_past?
      hearing_summaries_with_hearing_days.all? do |hs|
        hs.hearing_days.map(&:sitting_day).max&.in_time_zone&.past?
      end
    end

    def all_hearings_in_future?
      hearing_summaries_with_hearing_days.all? do |hs|
        hs.hearing_days.map(&:sitting_day).max&.in_time_zone&.future?
      end
    end

    def hearing_summaries_with_hearing_days
      prosecution_case_summary.hearing_summaries.reject { |hs| hs.hearing_days.blank? }
    end

    def offences
      defendant_summary.offence_summaries.map do |offence_summary|
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
