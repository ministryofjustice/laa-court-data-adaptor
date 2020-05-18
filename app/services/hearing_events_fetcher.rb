# frozen_string_literal: true

class HearingEventsFetcher < ApplicationService
  URL = 'LAAGetHearingEventLogHttpTriggerFast'

  def initialize(hearing_id:, hearing_date:, connection: CommonPlatformConnection.call)
    @params = { hearingId: hearing_id, date: hearing_date }
    @connection = connection
  end

  def call
    connection.get(URL, params)
  end

  private

  attr_reader :params, :connection
end
