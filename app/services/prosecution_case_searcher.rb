# frozen_string_literal: true

class ProsecutionCaseSearcher < ApplicationService
  URL = '/prosecutionCases'
  # rubocop:disable Metrics/ParameterLists
  def initialize(prosecution_case_reference: nil,
                 national_insurance_number: nil,
                 arrest_summons_number: nil,
                 first_name: nil,
                 last_name: nil,
                 date_of_birth: nil,
                 date_of_next_hearing: nil,
                 shared_key: ENV['SHARED_SECRET_KEY_SEARCH_PROSECUTION_CASE'],
                 connection: CommonPlatformConnection.call)
    @headers = { 'Ocp-Apim-Subscription-Key' => shared_key }
    @connection = connection
    @prosecution_case_reference = prosecution_case_reference
    @national_insurance_number = national_insurance_number
    @arrest_summons_number = arrest_summons_number
    @first_name = first_name
    @last_name = last_name
    @date_of_birth = date_of_birth
    @date_of_next_hearing = date_of_next_hearing
  end
  # rubocop:enable Metrics/ParameterLists

  def call
    connection.get(URL, request_params, headers)
  end

  private

  def request_params
    return { prosecutionCaseReference: prosecution_case_reference } if prosecution_case_reference.present?
    return { arrestSummonsNumber: arrest_summons_number } if arrest_summons_number.present?
    return { name: { firstName: first_name, lastName: last_name }, dateOfNextHearing: date_of_next_hearing } if date_of_next_hearing.present?
    return { name: { firstName: first_name, lastName: last_name }, dateOfBirth: date_of_birth } if date_of_birth.present?

    { nationalInsuranceNumber: national_insurance_number }
  end

  attr_reader :prosecution_case_reference,
              :national_insurance_number,
              :response,
              :arrest_summons_number,
              :first_name,
              :last_name,
              :date_of_birth,
              :date_of_next_hearing,
              :headers,
              :connection
end
