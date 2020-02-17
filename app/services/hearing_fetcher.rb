# frozen_string_literal: true

class HearingFetcher < ApplicationService
  def initialize(hearing_id:, shared_key: ENV['SHARED_SECRET_KEY_HEARING'], connection: CommonPlatformConnection.call)
    @url = 'hearing/result/LAAGetHearingHttpTrigger'
    @params = { hearingId: hearing_id }
    @headers = { 'Ocp-Apim-Subscription-Key' => shared_key }
    @connection = connection
  end

  def call
    connection.get(url, params, headers)
  end

  private

  attr_reader :url, :params, :headers, :connection
end
