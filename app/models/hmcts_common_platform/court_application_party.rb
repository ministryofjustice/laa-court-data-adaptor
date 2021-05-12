module HmctsCommonPlatform
  class CourtApplicationParty
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:id]
    end

    def synonym
      data[:synonym]
    end

    def summons_required
      data[:summonsRequired]
    end

    def notification_required
      data[:notificationRequired]
    end
  end
end
