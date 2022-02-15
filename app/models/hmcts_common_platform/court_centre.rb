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

    def welsh_name
      data[:welshName]
    end

    def room_id
      data[:roomId]
    end

    def room_name
      data[:roomName]
    end

    def welsh_room_name
      data[:welshRoomName]
    end

    def welsh_court_centre
      data[:welshCourtCentre]
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

    def address
      HmctsCommonPlatform::Address.new(data[:address])
    end

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |court_centre|
        court_centre.id id
        court_centre.name name
        court_centre.welsh_name welsh_name
        court_centre.room_id room_id
        court_centre.room_name room_name
        court_centre.welsh_room_name welsh_room_name
        court_centre.welsh_court_centre welsh_court_centre
        court_centre.short_oucode short_oucode
        court_centre.oucode_l2_code oucode_l2_code
        court_centre.code code
        court_centre.address address.to_json
      end
    end
  end
end
