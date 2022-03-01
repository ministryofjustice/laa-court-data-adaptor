module HmctsCommonPlatform
  class AllocationDecision
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def originating_hearing_id
      data[:originatingHearingId]
    end

    def offence_id
      data[:offenceId]
    end

    def mot_reason_id
      data[:motReasonId]
    end

    def mot_reason_description
      data[:motReasonDescription]
    end

    def mot_reason_code
      data[:motReasonCode]
    end

    def date
      data[:allocationDecisionDate]
    end

    def sequence_number
      data[:sequenceNumber]
    end

    def court_indicated_sentence
      HmctsCommonPlatform::CourtIndicatedSentence.new(data[:courtIndicatedSentence])
    end

    def to_json(*_args)
      return {} if attrs.all? { |_k, v| v.blank? }

      attrs
    end

  private

    def attrs
      @attrs ||= to_builder.attributes!
    end

    def to_builder
      Jbuilder.new do |allocation_decision|
        allocation_decision.date date
        allocation_decision.originating_hearing_id originating_hearing_id
        allocation_decision.offence_id offence_id
        allocation_decision.mot_reason_id mot_reason_id
        allocation_decision.mot_reason_description mot_reason_description
        allocation_decision.mot_reason_code mot_reason_code
        allocation_decision.sequence_number sequence_number
        allocation_decision.court_indicated_sentence court_indicated_sentence.to_json
      end
    end
  end
end
