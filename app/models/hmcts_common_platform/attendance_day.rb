module HmctsCommonPlatform
  class AttendanceDay
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def type
      data[:attendanceType]
    end

    def day
      data[:day]
    end

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |attendance_day|
        attendance_day.type type
        attendance_day.day day
      end
    end
  end
end
