module CommonPlatform::Api::Errors
  class FailedDependency < StandardError
    def codes
      [:commmon_platform_connection_failed]
    end
  end
end
