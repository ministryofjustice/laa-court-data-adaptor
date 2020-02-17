# frozen_string_literal: true

class Defendant < ApplicationRecord
  validates :body, presence: true

  attr_accessor :gender, :address_1, :address_2, :address_3, :address_4, :address_5, :postcode

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

  # TODO: this is pseudocode only at the moment to demonstrate logic
  def add_hearing_data
    offence_ids.each do |offence_id|
      offence = Offence.find(offence_id)
      next unless offence.application_reference.present?

      hearing_summaries = HearingSummary.where(defendants: [id])
      hearing_summaries.each do |hearing_summary|
        hearing_result = Api::GetHearingResults.new(hearing_summary.id)
        self.gender = hearing_result.gender
        update_defendant_address(hearing_result.address)
        hearing_summary.hearing_date = hearing_result.hearing_date
      end
    end
  end

  private

  def update_defendant_address(address)
    self.address_1 = address.address1
    self.address_2 = address.address2
    self.address_3 = address.address3
    self.address_4 = address.address4
    self.address_5 = address.address5
    self.postcode = address.postcode
  end
end
