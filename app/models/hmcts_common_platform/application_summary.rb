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

    def type
      data[:applicationType]
    end

    def application_status
      data[:applicationStatus]
    end

    def application_external_creator_type
      data[:applicationExternalCreatorType]
    end

    def received_date
      data[:receivedDate]
    end

    def decision_date
      data[:decisionDate]
    end

    def due_date
      data[:dueDate]
    end

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |application_summary|
        application_summary.id id
        application_summary.reference reference
        application_summary.type type
        application_summary.applicationStatus application_status
        application_summary.applicationExternalCreatorType application_external_creator_type
        application_summary.receivedDate received_date
        application_summary.decisionDate decision_date
        application_summary.dueDate due_date
      end
    end
  end
end
