module HmctsCommonPlatform
  class CourtCentre
    attr_reader :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:id]
    end

    def name
      data[:name]
    end

    def room_id
      data[:roomId]
    end

    def room_name
      data[:roomName]
    end
  end
end
