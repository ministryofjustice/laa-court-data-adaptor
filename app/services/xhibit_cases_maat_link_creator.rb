class XhibitCasesMaatLinkCreator < ApplicationService
  attr_reader :xhibit_migrated_case, :defendant_id, :user_name, :maat_reference

  def initialize(xhibit_migrated_case:, defendant_id:, user_name:, maat_reference:)
    @xhibit_migrated_case = xhibit_migrated_case
    @defendant_id = defendant_id
    @user_name = user_name
    @maat_reference = maat_reference.presence || LaaReference.generate_linking_dummy_maat_reference
  end

  def call
    ActiveRecord::Base.transaction do
      create_maat_link!
      update_xhibit_migrated_case!
    end
  end

private

  def create_maat_link!
    resolve_link_creator_class.call(
      defendant_id,
      user_name,
      maat_reference,
    )
  end

  def update_xhibit_migrated_case!
    xhibit_migrated_case.update!(
      maat_id: maat_reference,
      status: :manually_linked,
      linked_at: Time.zone.now,
      linked_by: user_name,
    )
  end

  def resolve_link_creator_class
    @xhibit_migrated_case.trial? ? ProsecutionCaseMaatLinkCreator : CourtApplicationMaatLinkCreator
  end
end
