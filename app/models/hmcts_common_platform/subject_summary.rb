module HmctsCommonPlatform
  class SubjectSummary
    attr_reader :data, :application_summary

    def initialize(data, application_summary = nil)
      @data = HashWithIndifferentAccess.new(data || {})
      @application_summary = application_summary
    end

    def date_of_next_hearing
      data[:dateOfNextHearing]
    end

    def defendant_asn
      data[:defendantASN]
    end

    def defendant_dob
      data[:defendantDOB]
    end

    def defendant_first_name
      data[:defendantFirstName]
    end

    def defendant_nino
      data[:defendantNINO]
    end

    def defendant_last_name
      data[:defendantLastName]
    end

    def proceedings_concluded
      data[:proceedingsConcluded]
    end

    def subject_id
      data[:subjectId]
    end

    def master_defendant_id
      data[:masterDefendantId]
    end

    def organisation_name
      data[:organisationName]
    end

    def representation_order
      HmctsCommonPlatform::RepresentationOrder.new(data[:representationOrder])
    end

    def offence_summary
      offence_payload.map do |summary_object|
        HmctsCommonPlatform::OffenceSummary.new(summary_object, subject_id)
      end
    end

    def to_json(*_args)
      # Warning: this `to_json` method doesn't return JSON, it returns a hash.
      # This is to be consistent with other models in this repo
      to_builder.attributes!
    end

    def has_offences?
      data[:offenceSummary].present?
    end

  private

    def to_builder
      Jbuilder.new do |summary|
        summary.subject_id subject_id
        summary.date_of_next_hearing date_of_next_hearing
        summary.defendant_asn defendant_asn
        summary.defendant_dob defendant_dob
        summary.defendant_first_name defendant_first_name
        summary.defendant_last_name defendant_last_name
        summary.master_defendant_id master_defendant_id
        summary.offence_summary offence_summary.map(&:to_json)
        summary.proceedings_concluded proceedings_concluded
        summary.organisation_name organisation_name
        summary.representation_order representation_order.to_json
      end
    end

    def offence_payload
      return Array(data[:offenceSummary]) if has_offences? || application_summary.nil?

      # For court applications without offences (e.g. breaches) we construct
      # a 'dummy' offence
      [
        {
          "offenceId": application_summary.application_id,
          "offenceCode": application_summary.application_type,
          "asnSeq": 1,
          "offenceDate": application_summary.received_date,
          "offenceShortTitle": application_summary.application_title,
        },
      ]
    end
  end
end
