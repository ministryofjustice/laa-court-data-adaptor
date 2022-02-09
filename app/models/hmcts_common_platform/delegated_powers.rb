module HmctsCommonPlatform
  class DelegatedPowers
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def user_id
      data[:userId]
    end

    def first_name
      data[:firstName]
    end

    def last_name
      data[:lastName]
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
      Jbuilder.new do |dp|
        dp.user_id user_id
        dp.first_name first_name
        dp.last_name last_name
      end
    end
  end
end
