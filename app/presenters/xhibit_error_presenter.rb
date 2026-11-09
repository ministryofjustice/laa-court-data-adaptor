class XhibitErrorPresenter
  # Maps internal error structures to user-friendly reasons for caseworkers
  # Used by VCD "Reason for manual linking" column

  REASONS = {
    maat_not_found: "MAAT application not found for this defendant",
    maat_linked_to_cp: "MAAT record is linked to another court case",
    maat_link_unknown: "Cannot verify MAAT record status—manual review needed",
    cp_not_found: "Case not found on Common Platform",
  }.freeze

  def initialize(process_errors)
    @process_errors = process_errors || {}
  end

  def self.reason_for_error(process_errors)
    new(process_errors).reason
  end

  def reason
    REASONS[error_type]
  end

private

  attr_reader :process_errors

  def error_type
    # Check MAAT errors first
    if maat_error?
      case maat_message
      when "MAAT application not found"
        :maat_not_found
      when /^MAAT ID already linked with other CP case/
        :maat_linked_to_cp
      when "MAAT link status could not be determined"
        :maat_link_unknown
      end
    elsif cp_error?
      case cp_message
      when "Case not found on Common Platform"
        :cp_not_found
      end
    end
  end

  def maat_error?
    process_errors.key?("maat")
  end

  def cp_error?
    process_errors.key?("common_platform")
  end

  def maat_message
    process_errors.dig("maat", "message") || ""
  end

  def cp_message
    process_errors.dig("common_platform", "message") || ""
  end
end
