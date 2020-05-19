# frozen_string_literal: true

class Hearing < ApplicationRecord
  validates :body, presence: true, unless: :events?
  validates :events, presence: true, unless: :body?

  def court_name
    body['courtCentre']['name']
  end

  def hearing_type
    body['type']['description']
  end

  def defendant_names
    defendants.map do |defendant|
      "#{defendant['personDefendant']['personDetails']['firstName']} #{defendant['personDefendant']['personDetails']['lastName']}"
    end
  end

  private

  def prosecution_cases
    body['prosecutionCases']
  end

  def defendants
    prosecution_cases.flat_map { |prosecution_case| prosecution_case['defendants'] }
  end
end
