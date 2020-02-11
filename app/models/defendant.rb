# frozen_string_literal: true

class Defendant
  include ActiveModel::Model

  attr_accessor :body

  def id
    body['defendantId']
  end

  def first_name
    body['name']['firstName']
  end

  def last_name
    body['name']['lastName']
  end

  def date_of_birth
    body['dateOfBirth']
  end

  def national_insurance_number
    body['nationalInsuranceNumber']
  end
end
