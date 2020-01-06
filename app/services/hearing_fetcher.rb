# frozen_string_literal: true

class HearingFetcher < ApplicationService
  include CommonPlatformConnection

  attr_reader :url, :params, :headers

  def initialize(hearing_id:, shared_key: ENV['SHARED_SECRET_KEY_HEARING'])
    @url = 'hearing/result-sit/LAAGetHearingHttpTrigger'
    @params = { hearingId: hearing_id }
    @headers = { 'LAHearing-Subscription-Key' => shared_key }
  end

  def call
    common_platform_connection.get(url, params, headers)
  end
end
