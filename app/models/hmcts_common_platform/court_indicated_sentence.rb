module HmctsCommonPlatform
  class CourtIndicatedSentence
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def type_id
      data[:courtIndicatedSentenceTypeId]
    end

    def description
      data[:courtIndicatedSentenceDescription]
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
      Jbuilder.new do |sentence|
        sentence.type_id type_id
        sentence.description description
      end
    end
  end
end
