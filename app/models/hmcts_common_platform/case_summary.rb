module HmctsCommonPlatform
  class CaseSummary
    attr_reader :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def case_status
      data[:caseStatus]
    end

    def prosecution_case_id
      data[:prosecutionCaseId]
    end

    def prosecution_case_reference
      data[:prosecutionCaseReference]
    end

    def to_json(*_args)
      # Warning: this `to_json` method doesn't return JSON, it returns a hash.
      # This is to be consistent with other models in this repo
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |summary|
        summary.case_status case_status
        summary.prosecution_case_id prosecution_case_id
        summary.prosecution_case_reference prosecution_case_reference
      end
    end
  end
end
