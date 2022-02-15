module HmctsCommonPlatform
  class CrackedIneffectiveTrial
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:id]
    end

    def code
      data[:code]
    end

    def description
      data[:description]
    end

    def type
      data[:type]
    end

    def date
      data[:date]
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
      Jbuilder.new do |cit|
        cit.id id
        cit.code code
        cit.description description
        cit.type type
        cit.date date
      end
    end
  end
end
