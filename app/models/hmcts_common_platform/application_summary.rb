module HmctsCommonPlatform
  class ApplicationSummary
    attr_accessor :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end
  end
end
