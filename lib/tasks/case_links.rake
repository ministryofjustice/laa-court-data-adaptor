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
        ProsecutionCaseLaaReferenceUnlinker.call(
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

  desc "Manually link a defendant with a large number of offences to MAAT using throttled CP API calls.
        This task waits 1 second between each offence posted to CP to avoid rate limit (429) errors.
        All offences are posted on every run, so the task can be safely re-run.
        Example: rake case_links:link_prosecution_case_with_many_offences 1234567 peter 2ecc9feb-9407-482f-b081-d9e5c8ba3ed3"
  task link_prosecution_case_with_many_offences: :environment do |_task, _args|
    maat_reference = ARGV[1]
    user_name = ARGV[2]
    defendant_id = ARGV[3]

    unless maat_reference.present? && user_name.present? && defendant_id.present?
      puts "[ERROR] Missing required arguments. Usage: rake case_links:link_prosecution_case_with_many_offences MAAT_ID USER_NAME DEFENDANT_ID"
      exit 1
    end

    puts "[INFO - #{Time.zone.now}] Starting linking process for a prosecution case with many offences..."
    puts "[INFO - #{Time.zone.now}] MAAT Reference: #{maat_reference}, User: #{user_name}, Defendant ID: #{defendant_id}"

    begin
      params = { maat_reference:, user_name:, defendant_id: }
      contract = ProsecutionCaseLaaReferenceContract.new.call(**params)
      raise Errors::ContractError.new(contract, "Contract") unless contract.success?

      Current.set(request_id: SecureRandom.uuid) do
        ProsecutionCaseMaatLinkCreator.call(defendant_id, user_name, maat_reference, offence_delay: 1)
      end

      puts "[INFO - #{Time.zone.now}] Successfully linked defendant #{defendant_id} to MAAT ID #{maat_reference}"
    rescue StandardError => e
      puts "[ERROR - #{Time.zone.now}] Failed to link defendant: #{e.message}"
      puts e.backtrace.join("\n")
      exit 1
    end
  end

  desc "Manually link a court application subject with a large number of offences to MAAT using throttled CP API calls.
        This task waits 1 second between each offence posted to CP to avoid rate limit (429) errors.
        Example: rake case_links:link_court_application_with_many_offences 1234567 peter 2ecc9feb-9407-482f-b081-d9e5c8ba3ed3"
  task link_court_application_with_many_offences: :environment do |_task, _args|
    maat_reference = ARGV[1]
    user_name = ARGV[2]
    subject_id = ARGV[3]

    unless maat_reference.present? && user_name.present? && subject_id.present?
      puts "[ERROR] Missing required arguments. Usage: rake case_links:link_court_application_with_many_offences MAAT_ID USER_NAME SUBJECT_ID"
      exit 1
    end

    puts "[INFO - #{Time.zone.now}] Starting linking process for a court application with many offences..."
    puts "[INFO - #{Time.zone.now}] MAAT Reference: #{maat_reference}, User: #{user_name}, Subject ID: #{subject_id}"

    begin
      params = { maat_reference: maat_reference.to_i, user_name:, subject_id: }
      contract = CourtApplicationLaaReferenceContract.new.call(**params)
      raise Errors::ContractError.new(contract, "Contract") unless contract.success?

      Current.set(request_id: SecureRandom.uuid) do
        CourtApplicationMaatLinkCreator.call(subject_id, user_name, maat_reference, offence_delay: 1)
      end

      puts "[INFO - #{Time.zone.now}] Successfully linked court application subject #{subject_id} to MAAT ID #{maat_reference}"
    rescue StandardError => e
      puts "[ERROR - #{Time.zone.now}] Failed to link court application subject: #{e.message}"
      puts e.backtrace.join("\n")
      exit 1
    end
  end
end
