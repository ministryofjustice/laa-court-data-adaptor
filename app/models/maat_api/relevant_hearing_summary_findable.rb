module MaatApi
  module RelevantHearingSummaryFindable
    extend ActiveSupport::Concern

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
        hs.hearing_days.map(&:sitting_day).max&.to_datetime&.past?
      end
    end

    def all_hearings_in_past?
      hearing_summaries_with_hearing_days.all? do |hs|
        hs.hearing_days.map(&:sitting_day).max&.to_datetime&.past?
      end
    end

    def all_hearings_in_future?
      hearing_summaries_with_hearing_days.all? do |hs|
        hs.hearing_days.map(&:sitting_day).max&.to_datetime&.future?
      end
    end

    def hearing_summaries_with_hearing_days
      hearing_summaries.reject { |hs| hs.hearing_days.blank? }
    end
  end
end
