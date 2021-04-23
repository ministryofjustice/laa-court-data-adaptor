module HmctsCommonPlatform
  class JudicialResult
    attr_reader :data

    def initialize(data)
      @data = data || {}
    end

    delegate :blank?, to: :data

    def code
      data[:cjsCode]
    end

    def label
      data[:label]
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

    def next_hearing_date
      data.dig(:nextHearing, :listedStartDateTime)
    end
  end
end
