# frozen_string_literal: true

class HearingFetcher < ApplicationService
  URL = 'LAAGetHearingHttpTrigger'

  def initialize(hearing_id:, shared_key: ENV['SHARED_SECRET_KEY'], connection: CommonPlatformConnection.call)
    @params = { hearingId: hearing_id }
    @headers = { 'Ocp-Apim-Subscription-Key' => shared_key }
    @connection = connection
  end

  def call
    connection.get(URL, params, headers)
  end

  private

  attr_reader :params, :headers, :connection
end
