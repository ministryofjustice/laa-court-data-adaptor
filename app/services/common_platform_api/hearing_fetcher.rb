# frozen_string_literal: true

module CommonPlatformApi
  class HearingFetcher < ApplicationService
    URL = "hearing/results"

    def initialize(hearing_id:, connection: CommonPlatformApi::Connection.call)
      @params = { hearingId: hearing_id }
      @connection = connection
    end

    def call
      connection.get(URL, params)
    end

  private

    attr_reader :params, :connection
  end
end
