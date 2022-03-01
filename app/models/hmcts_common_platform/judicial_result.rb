module HmctsCommonPlatform
  class JudicialResult
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:judicialResultId]
    end

    def cjs_code
      data[:cjsCode]
    end

    def is_adjournment_result
      data[:isAdjournmentResult]
    end

    def is_available_for_court_extract
      data[:isAvailableForCourtExtract]
    end

    def is_financial_result
      data[:isFinancialResult]
    end

    def is_convicted_result
      data[:isConvictedResult]
    end

    def label
      data[:label]
    end

    def category
      data[:category]
    end

    def text
      data[:resultText]
    end

    def qualifier
      data[:qualifier]
    end

    def ordered_date
      data[:orderedDate]
    end

    def wording
      data[:resultWording]
    end

    def post_hearing_custody_status
      data[:postHearingCustodyStatus]
    end

    def prompts
      Array(data[:judicialResultPrompts]).map do |prompt_data|
        HmctsCommonPlatform::JudicialResultPrompt.new(prompt_data)
      end
    end

    def next_hearing_court_centre_id
      data.dig(:nextHearing, :courtCentre, :id)
    end

    def next_hearing_court_centre
      HmctsCommonPlatform::CourtCentre.new(data.dig(:nextHearing, :courtCentre)) if data[:nextHearing]
    end

    def next_hearing_date
      data.dig(:nextHearing, :listedStartDateTime)
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
      Jbuilder.new do |judicial_result|
        judicial_result.id id
        judicial_result.label label
        judicial_result.is_adjournment_result is_adjournment_result
        judicial_result.is_available_for_court_extract is_available_for_court_extract
        judicial_result.is_convicted_result is_convicted_result
        judicial_result.is_financial_result is_financial_result
        judicial_result.qualifier qualifier
        judicial_result.text text
        judicial_result.cjs_code cjs_code
        judicial_result.ordered_date ordered_date
        judicial_result.post_hearing_custody_status post_hearing_custody_status
        judicial_result.wording wording
        judicial_result.prompts prompts.map(&:to_json)
      end
    end
  end
end
