module HmctsCommonPlatform
  class DefendantAttendance
    attr_reader :data

    delegate :blank?, to: :data

    def initialize(data)
      @data = HashWithIndifferentAccess.new(data || {})
    end

    def defendant_id
      data[:defendantId]
    end

    def attendance_days
      Array(data[:attendanceDays]).map do |attendance_day_data|
        HmctsCommonPlatform::AttendanceDay.new(attendance_day_data)
      end
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
      Jbuilder.new do |defendant_attendance|
        defendant_attendance.defendant_id defendant_id
        defendant_attendance.attendance_days attendance_days.map(&:to_json)
      end
    end
  end
end
