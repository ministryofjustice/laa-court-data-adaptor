require "securerandom"

namespace :maat_link_message do
  desc "Send a link confirmation message to MAAT for a specific defendant.
        This is used when the MAAT Assess team does not receive the link confirmation message.
        Example: rake maat_link_message:send DEFENDANT_ID=123 USER_NAME=john.doe MAAT_REFERENCE=M12345 COURT_CENTRE_ID=1 OUCODE=B01JQ"
  task send: :environment do
    defendant_id = ENV["DEFENDANT_ID"]
    user_name = ENV["USER_NAME"]
    maat_reference = ENV["MAAT_REFERENCE"]
    court_centre_id = ENV["COURT_CENTRE_ID"]
    oucode = ENV["OUCODE"]

    puts "[INFO - #{Time.zone.now}] Starting to send MAAT link message..."
    puts "[INFO - #{Time.zone.now}] Defendant ID: #{defendant_id}"
    puts "[INFO - #{Time.zone.now}] User: #{user_name}"
    puts "[INFO - #{Time.zone.now}] MAAT Reference: #{maat_reference}"
    puts "[INFO - #{Time.zone.now}] Court Centre ID: #{court_centre_id}"
    puts "[INFO - #{Time.zone.now}] OUCode: #{oucode}"

    begin
      request_id = SecureRandom.uuid
      Current.set(request_id:) do
        MaatLinkMessageSender.call(
          defendant_id:,
          user_name:,
          maat_reference:,
          court_centre_id:,
          oucode:,
        )
      end
      puts "[SUCCESS - #{Time.zone.now}] MAAT link message sent successfully for MAAT Reference: #{maat_reference}"
    rescue ArgumentError => e
      puts "[ERROR - #{Time.zone.now}] Validation error: #{e.message}"
      exit 1
    rescue StandardError => e
      puts "[ERROR - #{Time.zone.now}] Failed to send MAAT link message: #{e.message}"
      puts e.backtrace.join("\n")
      exit 1
    end
  end
end
