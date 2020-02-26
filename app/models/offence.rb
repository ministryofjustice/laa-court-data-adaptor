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
end
