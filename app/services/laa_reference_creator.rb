# frozen_string_literal: true

class LaaReferenceCreator < ApplicationService
  TEMPORARY_CREATED_USER = "cpUser"

  def initialize(defendant_id:, user_name: nil, maat_reference: nil)
    @defendant_id = defendant_id
    @user_name = user_name.presence || TEMPORARY_CREATED_USER
    @maat_reference = maat_reference.presence || dummy_maat_reference
  end

  def call
    create_laa_reference!
    MaatLinkCreatorWorker.perform_async(Current.request_id, laa_reference.id)
    laa_reference
  end

private

  def create_laa_reference!
    @laa_reference = LaaReference.create!(defendant_id: defendant_id, user_name: user_name, maat_reference: maat_reference, dummy_maat_reference: dummy_reference?)
  end

  def dummy_maat_reference
    @dummy_maat_reference ||= "A#{ActiveRecord::Base.connection.execute("SELECT nextval('dummy_maat_reference_seq')")[0]['nextval']}"
  end

  def dummy_reference?
    @dummy_maat_reference.present?
  end

  attr_reader :defendant_id, :user_name, :maat_reference, :laa_reference
end
