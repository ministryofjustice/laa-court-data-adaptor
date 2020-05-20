# frozen_string_literal: true

class Offence
  include ActiveModel::Model

  attr_accessor :body

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
    plea_hash['pleaValue'] if plea_hash.present?
  end

  def plea_date
    plea_hash['pleaDate'] if plea_hash.present?
  end

  private

  def laa_reference
    body['laaApplnReference']
  end

  def plea_hash
    body['plea']
  end
end
