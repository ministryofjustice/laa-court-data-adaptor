# frozen_string_literal: true

class DefenceOrganisation
  include ActiveModel::Model

  attr_accessor :body

  def id
    body["laaContractNumber"]
  end

  def name
    body.dig("organisation", "name")
  end

  def address1
    body.dig("organisation", "address", "address1")
  end

  def address2
    body.dig("organisation", "address", "address2")
  end

  def address3
    body.dig("organisation", "address", "address3")
  end

  def address4
    body.dig("organisation", "address", "address4")
  end

  def address5
    body.dig("organisation", "address", "address5")
  end

  def postcode
    body.dig("organisation", "address", "postcode")
  end
end
