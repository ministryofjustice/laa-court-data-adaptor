module HmctsCommonPlatform
  class JudicialRole
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def title
      data[:title]
    end

    def first_name
      data[:firstName]
    end

    def middle_name
      data[:middleName]
    end

    def last_name
      data[:lastName]
    end

    def is_deputy
      data[:isDeputy]
    end

    def is_bench_chairman
      data[:isBenchChairman]
    end

    def type
      data.dig(:judicialRoleType, :judiciaryType)
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
      Jbuilder.new do |judicial_role|
        judicial_role.title title
        judicial_role.first_name first_name
        judicial_role.middle_name middle_name
        judicial_role.last_name last_name
        judicial_role.type type
        judicial_role.is_deputy is_deputy
        judicial_role.is_bench_chairman is_bench_chairman
      end
    end
  end
end
