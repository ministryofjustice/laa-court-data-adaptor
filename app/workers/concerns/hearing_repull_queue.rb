# frozen_string_literal: true

# Repulls send traffic to Common Platform and, via SQS, to downstream LAA
# systems such as MAAT. Neither can absorb a large burst, so callers stagger
# jobs on this queue by DELAY_BETWEEN_JOBS rather than enqueuing them at once.
module HearingRepullQueue
  extend ActiveSupport::Concern

  DELAY_BETWEEN_JOBS = 10.seconds

  included do
    sidekiq_options queue: :hearing_repull
  end
end
