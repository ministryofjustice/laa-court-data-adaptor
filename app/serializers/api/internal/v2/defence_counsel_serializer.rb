module Api
  module Internal
    module V2
      class DefenceCounselSerializer
        include JSONAPI::Serializer

        attributes :title, :first_name, :middle_name, :last_name, :status, :attendance_days, :defendants
      end
    end
  end
end
