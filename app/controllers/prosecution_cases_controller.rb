# frozen_string_literal: true

class ProsecutionCasesController < ApplicationController
  def index
    @prosecution_cases = Api::SearchProsecutionCase.call(normalised_params)

    render json: @prosecution_cases, status: response_status
  end

  private

  def response_status
    @prosecution_cases.present? ? :ok : :not_found
  end

  def normalised_params
    permitted_params.transform_keys(&:underscore).to_h.symbolize_keys
  end

  def permitted_params
    params.require(:prosecutionCaseSearch).permit(:prosecutionCaseReference, :arrestSummonsNumber, :name, :dateOfBirth, :dateOFNextHearing, :nationalInsuranceNumber)
  end
end
