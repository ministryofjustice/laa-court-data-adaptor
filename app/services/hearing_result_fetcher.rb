# frozen_string_literal: true

class HearingResultFetcher < ApplicationService
  attr_reader :hearing_id, :sitting_day, :defendant_id

  def initialize(hearing_id, sitting_day, defendant_id)
    @hearing_id = hearing_id
    @sitting_day = sitting_day
    @defendant_id = defendant_id
  end

  def call
    response = CommonPlatform::Api::HearingFetcher.call(
      hearing_id:,
      sitting_day:,
    )

    if response.success?
      if response.body.present?
        HearingsCreator.call(
          hearing_resulted_data: CommonPlatform::HearingResultsFilter.call(response.body, defendant_id:),
          queue_url: Rails.configuration.x.aws.sqs_url_hearing_resulted,
        )
      else
        msg = log_for("Past result for hearing ID #{hearing_id} is not available.")
        Rails.logger.info(msg)
      end
    end

    if (300..499).cover?(response.status)
      msg = log_for("Unable to fetch past result of hearing ID #{hearing_id}: Common Platform responded with status code #{response.status}.")
      Rails.logger.info(msg)
    end

    if (500..599).cover?(response.status) # Server Error 5XX
      msg = log_for("Unable to fetch past result of hearing ID #{hearing_id}: Common Platform responded with status code #{response.status}.")

      raise Faraday::ServerError, msg # this tells Sidekiq to Retry
    end
  end

private

  def log_for(msg)
    "[#{Current.request_id}] - #{msg}"
  end
end
