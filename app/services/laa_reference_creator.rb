# frozen_string_literal: true

class LaaReferenceCreator < ApplicationService
  def initialize(maat_reference: nil, defendant_id:)
    @defendant_id = defendant_id
    @maat_reference = maat_reference
  end

  def call
    contract.call(laa_reference_params.compact)
  end

  private

  def laa_reference_params
    { maat_reference: maat_reference, defendant_id: defendant_id }
  end

  def contract
    NewLaaReferenceContract.new
  end

  attr_reader :defendant_id, :maat_reference
end
