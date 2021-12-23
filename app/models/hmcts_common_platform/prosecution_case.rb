module HmctsCommonPlatform
  class ProsecutionCase
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:id]
    end

    def urn
      data.dig(:prosecutionCaseIdentifier, :caseURN)
    end

    def defendant_ids
      defendants.map(&:id)
    end

    def defendants
      Array(data[:defendants]).map do |defendant_data|
        HmctsCommonPlatform::Defendant.new(defendant_data)
      end
    end
  end
end
