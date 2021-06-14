module HmctsCommonPlatform
  class DefendantCase
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def defendant_id
      data[:defendantId]
    end
  end
end
