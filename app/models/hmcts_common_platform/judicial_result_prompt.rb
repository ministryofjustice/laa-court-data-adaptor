module HmctsCommonPlatform
  class JudicialResultPrompt
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def type_id
      data[:judicialResultPromptTypeId]
    end

    def label
      data[:label]
    end

    def is_available_for_court_extract
      data[:isAvailableForCourtExtract]
    end

    def welsh_label
      data[:welshLabel]
    end

    def value
      data[:value]
    end

    def welsh_value
      data[:welshValue]
    end

    def qualifier
      data[:qualifier]
    end

    def duration_sequence
      data[:durationSequence]
    end

    def prompt_sequence
      data[:promptSequence]
    end

    def prompt_reference
      data[:promptReference]
    end

    def total_penalty_points
      data[:totalPenaltyPoints]
    end

    def is_financial_imposition
      data[:isFinancialImposition]
    end

    def user_groups
      data[:usergroups]
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
      Jbuilder.new do |prompt|
        prompt.type_id type_id
        prompt.is_available_for_court_extract is_available_for_court_extract
        prompt.label label
        prompt.welsh_label welsh_label
        prompt.value value
        prompt.welsh_value welsh_value
        prompt.qualifier qualifier
        prompt.duration_sequence duration_sequence
        prompt.prompt_sequence prompt_sequence
        prompt.prompt_reference prompt_reference
        prompt.total_penalty_points total_penalty_points
        prompt.is_financial_imposition is_financial_imposition
        prompt.user_groups user_groups
      end
    end
  end
end
