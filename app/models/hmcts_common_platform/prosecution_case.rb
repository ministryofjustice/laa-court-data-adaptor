module HmctsCommonPlatform
  class ProsecutionCase
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def urn
      data.dig(:prosecutionCaseIdentifier, :caseURN)
    end

    def defendants
      Array(data[:defendants]).map do |defendant_data|
        HmctsCommonPlatform::Defendant.new(defendant_data)
      end
    end
  end
end
