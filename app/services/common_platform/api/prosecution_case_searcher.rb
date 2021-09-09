# frozen_string_literal: true

module CommonPlatform
  module Api
    class ProsecutionCaseSearcher < ApplicationService
      URL = "prosecutionCases"
      def initialize(prosecution_case_reference: nil,
                     national_insurance_number: nil,
                     arrest_summons_number: nil,
                     name: nil,
                     date_of_birth: nil,
                     date_of_next_hearing: nil,
                     connection: CommonPlatform::Connection.call)
        @connection = connection
        @params = { prosecutionCaseReference: prosecution_case_reference,
                    defendantASN: arrest_summons_number,
                    defendantName: name,
                    dateOfNextHearing: date_of_next_hearing,
                    defendantDOB: date_of_birth,
                    defendantNINO: national_insurance_number }.compact
      end

      def call
        connection.get(URL, params)
      end

    private

      attr_reader :connection,
                  :params
    end
  end
end
