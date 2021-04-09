module HmctsCommonPlatform
  class DelegatedPowers
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def user_id
      data[:userId]
    end

    def first_name
      data[:firstName]
    end

    def last_name
      data[:lastName]
    end
  end
end
