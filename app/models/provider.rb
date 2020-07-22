# frozen_string_literal: true

class Provider
  include ActiveModel::Model

  attr_accessor :body

  def defence_advocate_name
    body.map { |detail| "#{detail['firstName']} #{detail['lastName']}" }
  end

  def defence_advocate_status
    body.map { |detail| "#{detail['status']}" }
  end
end
