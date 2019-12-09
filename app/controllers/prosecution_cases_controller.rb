# frozen_string_literal: true

class ProsecutionCasesController < ApplicationController
  def index
    @prosecution_cases = Api::SearchProsecutionCase.call(transformed_params)

    render json: @prosecution_cases, status: response_status
  end

  private

  def response_status
    @prosecution_cases.present? ? :ok : :not_found
  end

  def normalised_params
    Normaliser::MlraProsecutionCaseSearch.call(params)
  end

  def permitted_params
    normalised_params.require(:prosecution_case_search).permit(:prosecution_case_reference, :arrest_summons_number, :name, :date_of_birth, :date_of_next_hearing, :national_insurance_number)
  end

  def transformed_params
    permitted_params.to_hash.transform_keys(&:to_sym)
  end
end
