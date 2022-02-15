module HmctsCommonPlatform
  class ProsecutionCounsel
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

    def status
      data[:status]
    end

    def attendance_days
      data[:attendanceDays]
    end

    def prosecution_cases
      data[:prosecutionCases]
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
      Jbuilder.new do |prosecution_counsel|
        prosecution_counsel.title title
        prosecution_counsel.first_name first_name
        prosecution_counsel.middle_name middle_name
        prosecution_counsel.last_name last_name
        prosecution_counsel.status status
        prosecution_counsel.prosecution_cases prosecution_cases
        prosecution_counsel.attendance_days attendance_days
      end
    end
  end
end
