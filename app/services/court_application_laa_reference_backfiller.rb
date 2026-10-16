# Sets laa_references.court_application_id on court application links created before court_application_id existed.
#
# Every linked reference on a court application's subject id is an application link, unless that id is
# also a prosecution case defendant id (e.g. CP reusing the masterDefendantId).
class CourtApplicationLaaReferenceBackfiller < ApplicationService
  def initialize(apply: false)
    @apply = apply
  end

  def call
    to_update = []
    skipped = []

    CourtApplication.find_each do |court_application|
      laa_references = LaaReference.where(defendant_id: court_application.subject_id, court_application_id: nil, linked: true)

      if prosecution_case_defendant?(court_application.subject_id)
        skipped.concat(laa_references.pluck(:maat_reference))
      else
        to_update.concat(laa_references.pluck(:maat_reference))
        laa_references.update_all(court_application_id: court_application.id) if @apply
      end
    end

    { to_update:, skipped: }
  end

private

  # Ignores court applications stored as prosecution cases (until July 2025).
  def prosecution_case_defendant?(subject_id)
    ProsecutionCaseDefendantOffence.where(defendant_id: subject_id)
                                   .where.not(prosecution_case_id: CourtApplication.where(subject_id:).select(:id))
                                   .exists?
  end
end
