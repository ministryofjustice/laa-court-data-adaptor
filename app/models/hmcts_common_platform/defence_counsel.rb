module HmctsCommonPlatform
  class DefenceCounsel
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def id
      data[:id]
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

    def defendants
      data[:defendants]
    end
  end
end
