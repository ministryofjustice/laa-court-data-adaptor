require 'securerandom'

namespace :case_links do

  desc "Manually re-process the case unlinking where the input arguments are the MAAT ID and unlink reason code
        respectively.
        Example: rake case_links:unlink 1234 2"
  task unlink: :environment do |_task|
    maat_id = ARGV[0]
    unlink_reason = ARGV[1]

    puts "[INFO - #{Time.zone.now}] About to process unlinking of MAAT ID: #{maat_id} ..."
    request_id = SecureRandom.uuid
    laa_reference = LaaReference.find_by!(maat_reference: maat_id, linked: true)

    puts "[INFO - #{Time.zone.now}] Removing link between MAAT ID #{maat_id} and Defendant ID #{laa_reference.defendant_id} ..."

    Current.set(request_id: request_id) do
      LaaReferenceUnlinker.call(
        defendant_id: laa_reference.defendant_id,
        user_name: test,
        unlink_reason_code: unlink_reason.to_i,
        unlink_other_reason_text: "",
        )
    end

    rescue StandardError => e
      puts "[INFO - #{Time.zone.now}] There was an error unlinking MAAT ID: #{maat_id}: #{e.message}."
  end
end
