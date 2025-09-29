class LinkingStatCollator < ApplicationService
  def initialize(date_from, date_to)
    @date_from = date_from
    @date_to = date_to
  end

  # If a user requests stats for a specific range, we will return
  # overview stats for the 10 previous periods of the same duration
  # as the specified range in order to demonstrate trends over time
  NUMBER_OF_PREVIOUS_RANGES = 10

  attr_reader :date_from, :date_to

  def call
    {
      current_range:,
      previous_ranges:,
    }
  end

  # We are comparing dates to timestamps. By default a date is treated as being the very
  # start of the day, so to include all timestamps occurring on that day we need to set
  # the cutoff as being the start of the _following_ day.
  def date_to_cutoff
    date_to + 1.day
  end

  def current_range
    {
      date_from:,
      date_to:,
      linked: linked_count,
      unlinked: unlinked_count,
      unlink_reason_codes:,
      other_unlink_reasons:,
    }
  end

  delegate :count, to: :linked, prefix: true
  delegate :count, to: :unlinked, prefix: true

  def linked
    # This is all links that happened, whether or not the link was
    # subsequently unlinked
    LaaReference.where(created_at: date_from..date_to_cutoff)
  end

  def unlinked
    LaaReference.where(created_at: date_from..date_to_cutoff, linked: false)
  end

  def unlink_reason_codes
    unlinked.pluck(:unlink_reason_code).tally
  end

  def other_unlink_reasons
    unlinked.where.not(unlink_other_reason_text: nil).pluck(:unlink_other_reason_text)
  end

  def previous_ranges
    interval = (date_to_cutoff - date_from).to_i
    start = date_from - (NUMBER_OF_PREVIOUS_RANGES * interval).days
    # The below query looks at every link made over the course of the 10 periods
    # prior to the current period and groups them by period, tallying up
    # how many there were in total, and how many of them were subsequently unlinked.
    raw_data = LaaReference.group(:intervals_ago)
                           .order(:intervals_ago)
                           .where(created_at: start..date_from)
                           .select(Arel.sql("((?::date - created_at::date) / ?) + 1 AS intervals_ago,
                                            COUNT(id) AS total_linked,
                                            SUM(CASE WHEN linked = true THEN 0 ELSE 1 END) AS total_unlinked",
                                            date_from.to_s, interval))
    raw_data.map do |row|
      {
        date_from: date_from - (row.intervals_ago * interval).days,
        date_to: date_to - (row.intervals_ago * interval).days,
        linked: row.total_linked,
        unlinked: row.total_unlinked,
      }
    end
  end
end
