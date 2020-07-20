# frozen_string_literal: true

class Provider
  include ActiveModel::Model

  attr_accessor :body

  def defence_advocate_name
    body['firstName'] + ' ' + body['lastName']
  end
end
