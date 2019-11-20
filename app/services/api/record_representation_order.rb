# frozen_string_literal: true

module Api
  class RecordRepresentationOrder < ApplicationService
    include CommonPlatformConnection

    # rubocop:disable Metrics/ParameterLists
    def initialize(laa_reference_id:, prosecution_case_id:, defendant_id:, offence_id:, status_code:, application_reference:, status_date:, effective_start_date:, defence_organisation:)
      @prosecution_case_id = prosecution_case_id
      @defendant_id = defendant_id
      @offence_id = offence_id
      @status_code = status_code
      @application_reference = application_reference
      @status_date = status_date
      @effective_start_date = effective_start_date
      @defence_organisation = defence_organisation
      @url = "/prosecutionCases/representationOrder/#{laa_reference_id}"
    end
    # rubocop:enable Metrics/ParameterLists

    def call
      common_platform_connection.put(url, request_body)
    end

    private

    def request_body
      {
        prosecutionCaseId: prosecution_case_id,
        defendantId: defendant_id,
        offenceId: offence_id,
        statusCode: status_code,
        applicationReference: application_reference,
        statusDate: status_date,
        effectiveStartDate: effective_start_date,
        defenceOrganisation: defence_organisation
      }
    end

    attr_reader :url, :prosecution_case_id, :defendant_id, :offence_id, :status_code, :application_reference, :status_date, :effective_start_date, :defence_organisation
  end
end
