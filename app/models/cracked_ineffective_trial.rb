# frozen_string_literal: true

class CrackedIneffectiveTrial
  include ActiveModel::Model

  attr_accessor :body

  def id
    body["id"]
  end

  def code
    body["code"]
  end

  def description
    body["description"]
  end

  def type
    body["type"]&.downcase
  end
end
