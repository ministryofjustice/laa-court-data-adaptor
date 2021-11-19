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

    def next_hearing_court_centre_id
      data.dig(:nextHearing, :courtCentre, :id)
    end

    def next_hearing_court_centre
      HmctsCommonPlatform::CourtCentre.new(data.dig(:nextHearing, :courtCentre)) if data[:nextHearing]
    end

    def next_hearing_date
      data.dig(:nextHearing, :listedStartDateTime)
    end
  end
end
