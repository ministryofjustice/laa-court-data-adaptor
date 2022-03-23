module HmctsCommonPlatform
  class BailStatus
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def code
      data[:code]
    end

    def description
      data[:description]
    end

    def to_json(*_args)
      return {} if attrs.all? { |_k, v| v.blank? }

      attrs
    end

  private

    def to_builder
      Jbuilder.new do |bail_status|
        bail_status.code code
        bail_status.description description
      end
    end

    def attrs
      @attrs ||= to_builder.attributes!
    end
  end
end
