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

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |court_application_party|
        court_application_party.id id
        court_application_party.synonym synonym
        court_application_party.summons_required summons_required
        court_application_party.notification_required notification_required
      end
    end
  end
end
