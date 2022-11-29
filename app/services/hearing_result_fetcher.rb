# frozen_string_literal: true

class HearingResultFetcher < ApplicationService
  attr_reader :hearing_id, :sitting_day

  def initialize(hearing_id, sitting_day)
    @hearing_id = hearing_id
    @sitting_day = sitting_day
  end

  def call
    response = CommonPlatform::Api::HearingFetcher.call(
      hearing_id: hearing_id,
      sitting_day: sitting_day,
    )

    msg = "[#{Current.request_id}] - "

    if response.success? && response.body.blank?
      msg += "Past result for hearing ID #{hearing_id} is not available."
      Rails.logger.info(msg)
      raise StandardError, msg
    end

    unless response.success?
      msg += "Unable to fetch past result of hearing ID #{hearing_id}: Common Platform responded with status code #{response.status}."
      Rails.logger.info(msg)
      raise StandardError, msg
    end

    HearingsCreator.call(
      hearing_resulted_data: response.body.deep_stringify_keys,
      queue_url: Rails.configuration.x.aws.sqs_url_hearing_resulted,
    )
  end
end
