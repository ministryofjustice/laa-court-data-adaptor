module MaatApi
  module HearingSummarySelectable
    # Selects which hearing's court centre is reported to MAAT

    def relevant_hearing_summary
      return hearing_summaries.first if hearing_summaries_with_hearing_days.empty?

      most_recent_past_hearing_summary = past_hearing_summaries.max_by { |hs| sitting_days(hs) }
      next_upcoming_hearing_summary = hearing_summaries_with_hearing_days.min_by { |hs| sitting_days(hs) }

      most_recent_past_hearing_summary || next_upcoming_hearing_summary
    end

  private

    def past_hearing_summaries
      hearing_summaries_with_hearing_days.select { |hs| sitting_days(hs).max&.to_datetime&.past? }
    end

    def hearing_summaries_with_hearing_days
      hearing_summaries.reject { |hs| hs.hearing_days.blank? }
    end

    def sitting_days(hearing_summary)
      hearing_summary.hearing_days.map(&:sitting_day)
    end
  end
end
