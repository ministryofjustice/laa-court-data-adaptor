module HmctsCommonPlatform
  class LaaReference
    attr_reader :data, :defendant_id

    delegate :blank?, to: :data

    def initialize(data, defendant_id = nil)
      @data = HashWithIndifferentAccess.new(data || {})
      @defendant_id = defendant_id
    end

    def reference
      # HMCTS does not reliably tell us if there is a MAAT reference or not.
      ::LaaReference.find_by(defendant_id:, linked: true)&.maat_reference if defendant_id
    end

    def status_id
      data[:statusId]
    end

    def status_code
      data[:statusCode]
    end

    def status_date
      data[:statusDate]
    end

    def status_description
      data[:statusDescription]
    end

    def effective_start_date
      data[:effectiveStartDate]
    end

    def effective_end_date
      data[:effectiveEndDate]
    end

    def laa_contract_number
      data[:laaContractNumber]
    end

    def to_json(*_args)
      return {} if attrs.all? { |_k, v| v.nil? }

      attrs
    end

  private

    def attrs
      @attrs ||= to_builder.attributes!
    end

    def to_builder
      Jbuilder.new do |laa_reference|
        laa_reference.reference reference
        laa_reference.id status_id
        laa_reference.status_code status_code
        laa_reference.status_date status_date
        laa_reference.description status_description
        laa_reference.effective_start_date effective_start_date
        laa_reference.effective_end_date effective_end_date
        laa_reference.contract_number laa_contract_number
      end
    end
  end
end
