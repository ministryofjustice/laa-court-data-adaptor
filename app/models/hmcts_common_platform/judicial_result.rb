module HmctsCommonPlatform
  class JudicialResult
    attr_reader :data

    def initialize(data)
      @data = data
    end

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

    def next_hearing_date
      data.dig(:nextHearing, :listedStartDateTime)
    end

    def next_hearing_location
      find_court_centre_by_id(data.dig(:nextHearing, :courtCentre, :id))&.short_oucode
    end

  private

    def find_court_centre_by_id(id)
      return if id.blank?

      HmctsCommonPlatform::Reference::CourtCentre.find(id)
    end
  end
end
