# frozen_string_literal: true

class HearingEventsFetcher < ApplicationService
  URL = 'LAAGetHearingEventLogHttpTriggerFast'

  def initialize(hearing_id:, hearing_date:, shared_key: ENV['SHARED_SECRET_KEY'], connection: CommonPlatformConnection.call)
    @params = { hearingId: hearing_id, date: hearing_date }
    @headers = { 'Ocp-Apim-Subscription-Key' => shared_key }
    @connection = connection
  end

  def call
    connection.get(URL, params, headers)
  end

  private

  attr_reader :params, :headers, :connection
end
