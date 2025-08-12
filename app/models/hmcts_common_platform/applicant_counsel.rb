module HmctsCommonPlatform
  class ApplicantCounsel
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

    def applicants
      data[:applicants]
    end

    def to_json(*_args)
      to_builder.attributes!
    end

  private

    def to_builder
      Jbuilder.new do |defence_counsel|
        defence_counsel.id id
        defence_counsel.title title
        defence_counsel.first_name first_name
        defence_counsel.middle_name middle_name
        defence_counsel.last_name last_name
        defence_counsel.status status
        defence_counsel.attendance_days attendance_days
        defence_counsel.applicants applicants
      end
    end
  end
end
