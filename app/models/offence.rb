# frozen_string_literal: true

class Offence
  include ActiveModel::Model

  attr_accessor :body, :details

  def id
    body['offenceId']
  end

  def code
    body['offenceCode']
  end

  def order_index
    body['orderIndex']
  end

  def title
    body['offenceTitle']
  end

  def mode_of_trial
    body['modeOfTrial']
  end

  def maat_reference
    laa_reference['applicationReference'] if laa_reference.present?
  end

  def plea
    plea_hash['pleaValue']
  end

  def plea_date
    plea_hash['pleaDate']
  end

  private

  def laa_reference
    body['laaApplnReference']
  end

  def plea_hash
    return {} if details.blank?

    details['plea'] || {}
  end
end
