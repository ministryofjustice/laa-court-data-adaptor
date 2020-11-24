# frozen_string_literal: true

class HearingFetcher < ApplicationService
  URL = "hearing/results"

  def initialize(hearing_id:, connection: CommonPlatformConnection.call)
    @params = { hearingId: hearing_id }
    @connection = connection
  end

  def call
    connection.get(URL, params)
  end

private

  attr_reader :params, :connection
end
