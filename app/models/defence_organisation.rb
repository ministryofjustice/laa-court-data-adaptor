# frozen_string_literal: true

class DefenceOrganisation
  include ActiveModel::Model

  attr_accessor :body

  def id
    body['laaContractNumber']
  end

  def name
    body['organisation']['name']
  end

  def address1
    body['organisation']['address']['address1']
  end

  def address2
    body['organisation']['address']['address2']
  end

  def address3
    body['organisation']['address']['address3']
  end

  def address4
    body['organisation']['address']['address4']
  end

  def address5
    body['organisation']['address']['address5']
  end

  def postcode
    body['organisation']['address']['postcode']
  end
end
