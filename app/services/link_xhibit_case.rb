class LinkXhibitCase < ApplicationService
  class LinkFailure < StandardError; end

  def call(maat_search_response, xhibit_case)
    create_maat_link!(xhibit_case.defendant_id, maat_search_response.maat_id)
    update_xhibit_case!(xhibit_case, maat_search_response.maat_id)
  end

private

  def create_maat_link!(defendant_id, maat_id)
    CourtApplicationMaatLinkCreator.call(
      defendant_id,
      "SYSTEM",
      maat_id,
    )
  end

  def update_xhibit_case!(xhibit_case, maat_id)
    xhibit_case.update!(
      maat_id: maat_id,
      status: :auto_linked,
      linked_at: Time.zone.now,
      linked_by: "SYSTEM",
    )
  end
end
