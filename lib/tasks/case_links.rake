require "securerandom"

namespace :case_links do
  desc "Manually re-process the case unlinking where the input arguments are the MAAT ID and unlink reason code
        respectively.
        Example: rake case_links:unlink 1234 2"
  task unlink: :environment do |_task, _args|
    maat_id = ARGV[1]
    unlink_reason = ARGV[2]
    user = "CDA-MANUAL"
    unlink_reason_text = ""

    puts "[INFO - #{Time.zone.now}] About to process unlinking of MAAT ID: #{maat_id} for reason code #{unlink_reason}..."
    begin
      request_id = SecureRandom.uuid
      laa_reference = LaaReference.find_by!(maat_reference: maat_id, linked: true)

      puts "[INFO - #{Time.zone.now}] Removing link between MAAT ID #{maat_id} and Defendant ID #{laa_reference.defendant_id} ..."

      Current.set(request_id:) do
        LaaReferenceUnlinker.call(
          defendant_id: laa_reference.defendant_id,
          user_name: user,
          unlink_reason_code: unlink_reason,
          unlink_other_reason_text: unlink_reason_text,
        )
      end
    rescue StandardError => e
      puts "[INFO - #{Time.zone.now}] There was an error unlinking MAAT ID: #{maat_id}: #{e.message}."
    end
  end

  desc "Manually link a case with a large number of offences to MAAT using throttled CP API calls.
        This task introduces a 1 second delay between each offence linking to avoid rate limit (429) errors.
        Example: rake case_links:link_large_case 1234567 peter.rabbit 99LD1234567"
  task link_large_case: :environment do |_task, _args|
    maat_reference = ARGV[1]
    user_name = ARGV[2]
    prosecution_case_urn = ARGV[3]

    unless maat_reference.present? && user_name.present? && prosecution_case_urn.present?
      puts "[ERROR] Missing required arguments. Usage: rake case_links:link_large_case MAAT_ID USER_NAME CASE_URN"
      exit 1
    end

    puts "[INFO - #{Time.zone.now}] Starting large case linking process..."
    puts "[INFO - #{Time.zone.now}] MAAT Reference: #{maat_reference}, User: #{user_name}, Case URN: #{prosecution_case_urn}"

    begin
      request_id = SecureRandom.uuid
      Current.set(request_id:) do
        LinkLargeCaseWithThrottling.call(
          maat_reference:,
          user_name:,
          prosecution_case_urn:,
        )
      end

      puts "[INFO - #{Time.zone.now}] Successfully linked case #{prosecution_case_urn} to MAAT ID #{maat_reference}"
    rescue StandardError => e
      puts "[ERROR - #{Time.zone.now}] Failed to link case: #{e.message}"
      puts e.backtrace.join("\n")
      exit 1
    end
  end
end
