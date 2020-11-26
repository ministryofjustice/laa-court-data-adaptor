# frozen_string_literal: true

class Provider
  include ActiveModel::Model

  attr_accessor :body

  def name
    "#{body['firstName']} #{body['lastName']}"
  end

  def role
    body["status"]
  end

  def id
    body["id"]
  end
end
