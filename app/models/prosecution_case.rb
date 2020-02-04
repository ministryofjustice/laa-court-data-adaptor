# frozen_string_literal: true

class ProsecutionCase < ApplicationRecord
  validates :body, presence: true

  def defendant_first_name
    defendant['name']['firstName']
  end

  def defendant_last_name
    defendant['name']['lastName']
  end

  def prosecution_case_reference
    body['prosecutionCaseReference']
  end

  def date_of_birth
    defendant['dateOfBirth']
  end

  def national_insurance_number
    defendant['nationalInsuranceNumber']
  end

  private

  def defendant
    body['defendants'].first
  end
end
