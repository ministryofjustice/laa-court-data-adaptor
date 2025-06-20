module CommonPlatform::Api::Errors
  class FailedDependency < StandardError
    def codes
      [:common_platform_connection_failed]
    end
  end
end
