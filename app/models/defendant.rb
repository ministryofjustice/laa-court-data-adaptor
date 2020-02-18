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

  def gender
    body['gender']
  end

  def address_1
    body['address_1']
  end

  def address_2
    body['address_2']
  end

  def address_3
    body['address_3']
  end

  def address_4
    body['address_4']
  end

  def address_5
    body['address_5']
  end

  def postcode
    body['postcode']
  end

  def offences
    body['offences'].map { |offence| Offence.new(body: offence) }
  end

  def offence_ids
    offences.map(&:id)
  end
end
