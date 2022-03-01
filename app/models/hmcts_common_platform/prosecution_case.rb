module HmctsCommonPlatform
  class ProsecutionCase
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:id]
    end

    def urn
      prosecution_case_identifier.case_urn
    end

    def prosecution_case_identifier
      HmctsCommonPlatform::ProsecutionCaseIdentifier.new(data[:prosecutionCaseIdentifier])
    end

    def status
      data[:caseStatus]
    end

    def statement_of_facts
      data[:statementOfFacts]
    end

    def statement_of_facts_welsh
      data[:statementOfFactsWelsh]
    end

    def defendant_ids
      defendants.map(&:id)
    end

    def defendants
      Array(data[:defendants]).map do |defendant_data|
        HmctsCommonPlatform::Defendant.new(defendant_data)
      end
    end

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |pc|
        pc.id id
        pc.prosecution_case_identifier prosecution_case_identifier.to_json
        pc.status status
        pc.statement_of_facts statement_of_facts
        pc.statement_of_facts_welsh statement_of_facts_welsh
        pc.defendants defendants.map(&:to_json)
      end
    end
  end
end
