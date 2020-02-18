# frozen_string_literal: true

class Defendant
  include ActiveModel::Model

  attr_accessor :body, :gender, :address_1, :address_2, :address_3, :address_4, :address_5, :postcode

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

  def offences
    body['offences'].map { |offence| Offence.new(body: offence) }
  end

  def offence_ids
    offences.map(&:id)
  end
end
