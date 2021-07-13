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

    def short_oucode
      # Extract 5 first characters
      code[0..4] if code
    end

    def oucode_l2_code
      # Extract second and third characters, and strip any leading zeros
      code[1..2].sub(/^0*/, "") if code
    end

    def code
      data[:code] || HmctsCommonPlatform::Reference::CourtCentre.find(id).oucode
    end
  end
end
