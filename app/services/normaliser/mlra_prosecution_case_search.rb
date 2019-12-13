# frozen_string_literal: true

module Normaliser
  class MlraProsecutionCaseSearch < ApplicationService
    MAPPINGS = {
      'caseReference' => :prosecution_case_reference,
      'asn' => :arrest_summons_number,
      'nino' => :national_insurance_number,
      'dob' => :date_of_birth,
      'nextHearingDate' => :date_of_next_hearing,
      'lastName' => :last_name,
      'firstName' => :first_name
    }.freeze

    def initialize(params)
      @params = params[:prosecutionCases].permit!.to_h
    end

    def call
      transform_keys!
      transform_name_keys!
      ActionController::Parameters.new(prosecution_case_search: params)
    end

    private

    def transform_keys!
      params.transform_keys! { |k| MAPPINGS[k] }
    end

    def transform_name_keys!
      name_hash = params.slice(*name_params)
      params.except!(*name_params).merge!(name: name_hash)
    end

    def name_params
      %i[first_name last_name]
    end

    attr_reader :params
  end
end
