# frozen_string_literal: true

# Links a case whose MAAT application was linked to LIBRA, once the unlink
# message has had time to be processed (see ProcessXhibitCases::LIBRA_UNLINK_DELAY).
class LinkXhibitCaseWorker
  include Sidekiq::Worker

  def perform(xhibit_case_id, maat_id)
    xhibit_case = XhibitMigratedCase.find_by(id: xhibit_case_id)
    return unless xhibit_case&.pending?

    ProcessXhibitCases.new.link_to_common_platform(xhibit_case, maat_id)
  end
end
