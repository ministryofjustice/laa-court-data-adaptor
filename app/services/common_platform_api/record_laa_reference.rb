# frozen_string_literal: true

module CommonPlatformApi
  class RecordLaaReference < ApplicationService
    def initialize(prosecution_case_id:,
                   defendant_id:,
                   offence_id:,
                   status_code:,
                   application_reference:,
                   status_date:,
                   connection: CommonPlatformApi::Connection.call)

      @offence_id = offence_id
      @status_code = status_code
      @application_reference = application_reference.to_s
      @status_date = status_date
      @connection = connection
      @url = "prosecutionCases/laaReference"\
              "/cases/#{prosecution_case_id}"\
              "/defendant/#{defendant_id}"\
              "/offences/#{offence_id}"
    end

    def call
      response = connection.post(url, request_body)
      update_database(response)
      response
    end

  private

    def request_body
      {
        statusCode: status_code,
        applicationReference: application_reference,
        statusDate: status_date,
      }
    end

    def update_database(response)
      offence = ProsecutionCaseDefendantOffence.find_by(offence_id: offence_id)
      offence.rep_order_status = status_code
      offence.status_date = status_date
      offence.response_status = response.status
      offence.response_body = response.body
      offence.save!
    end

    attr_reader :url, :status_code, :application_reference, :status_date, :connection, :offence_id
  end
end
