module HmctsCommonPlatform
  class HearingType
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:id]
    end

    def description
      data[:description]
    end

    def welsh_description
      data[:welshDescription]
    end

    def to_json(*_args)
      return {} if attrs.all? { |_k, v| v.blank? }

      attrs
    end

  private

    def attrs
      @attrs ||= to_builder.attributes!
    end

    def to_builder
      Jbuilder.new do |hearing_type|
        hearing_type.id id
        hearing_type.description description
        hearing_type.welsh_description welsh_description
      end
    end
  end
end
