# frozen_string_literal: true

class LaaReferenceCreator < ApplicationService
  TEMPORARY_CREATED_USER = "cpUser"

  def initialize(defendant_id:, user_name: nil, maat_reference: nil)
    @defendant_id = defendant_id
    @user_name = user_name.presence || TEMPORARY_CREATED_USER
    @maat_reference = maat_reference.presence || LaaReference.generate_linking_dummy_maat_reference
  end

  def call
    persist_laa_reference!
    create_maat_link
    laa_reference
  end

private

  def persist_laa_reference!
    @laa_reference = LaaReference.create!(defendant_id: defendant_id,
                                          user_name: user_name,
                                          maat_reference: maat_reference)
  end

  def create_maat_link
    MaatLinkCreatorWorker.perform_async(Current.request_id, laa_reference.id)
  end

  attr_reader :defendant_id, :user_name, :maat_reference, :laa_reference
end
