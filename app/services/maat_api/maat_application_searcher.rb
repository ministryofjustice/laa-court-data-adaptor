# frozen_string_literal: true

module MaatApi
  class MaatApplicationSearcher < ApplicationService
    URL = "api/internal/v1/assessment/rep-orders/search-maat-application"

    def initialize(first_name: nil,
                   last_name: nil,
                   date_of_birth: nil,
                   national_insurance_number: nil,
                   arrest_summons_number: nil,
                   committal_date: nil,
                   case_type: nil,
                   connection: MaatApi::Connection.call)
      @connection = connection
      @search_request = { firstName: first_name,
                          lastName: last_name,
                          dob: date_of_birth,
                          niNumber: national_insurance_number,
                          asn: arrest_summons_number,
                          committalDate: committal_date,
                          caseType: case_type }.compact
    end

    def call
      @connection.presence&.post(URL, @search_request)
    end
  end
end
