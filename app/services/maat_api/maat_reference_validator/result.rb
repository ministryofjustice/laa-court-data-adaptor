module MaatApi
  class MaatReferenceValidator
    class Result
      ALREADY_LINKED_MESSAGE_FROM_MAAT = "is already linked to a case".freeze
      NO_COMMON_PLATFORM_MESSAGE_FROM_MAAT = "has no common platform data created".freeze

      def initialize(response)
        @response = response
      end

      def success?
        @response.nil? || @response.success?
      end

      def error_code
        return nil if success?

        message = @response.body["message"]
        if message.include?(ALREADY_LINKED_MESSAGE_FROM_MAAT)
          :already_linked
        elsif message.include?(NO_COMMON_PLATFORM_MESSAGE_FROM_MAAT)
          :no_common_platform_data
        else
          :invalid
        end
      end
    end
  end
end
