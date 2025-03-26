module HmctsCommonPlatform
  class ApplicationSummary
    attr_accessor :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:applicationId]
    end

    def reference
      data[:applicationReference]
    end

    def title
      data[:applicationTitle]
    end

    def received_date
      data[:receivedDate]
    end

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |application_summary|
        application_summary.id id
        application_summary.reference reference
        application_summary.title title
        application_summary.received_date received_date
      end
    end
  end
end
