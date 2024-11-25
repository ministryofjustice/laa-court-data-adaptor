namespace :hearings do
  desc "Fetch past hearings from HMCTS Common Platform for the given string of comma-separated MAAT IDs. \
        Example: rake hearings:fetch '1234, 5678'"
  task fetch: :environment do |_task, _args|
    maat_ids = ARGV.last.split(",")
    processed_maat_ids = []
    errored_maat_ids = []

    puts "[INFO - #{Time.zone.now}] About to process #{maat_ids.count} MAAT IDs ..."

    maat_ids.count.times do
      maat_id = maat_ids.shift

      puts "\n\n"
      puts "[INFO - #{Time.zone.now}] Processing #{maat_id} ..."

      begin
        puts "[INFO - #{Time.zone.now}] #{maat_ids.count} remaining."

        laa_reference       = LaaReference.find_by!(maat_reference: maat_id, linked: true)
        defendant_id        = laa_reference.defendant_id
        prosecution_case_id = ProsecutionCaseDefendantOffence.where(defendant_id:).first.prosecution_case_id

        CommonPlatform::Api::ProsecutionCaseHearingsFetcher.call(prosecution_case_id:)
      rescue StandardError => e
        puts "[INFO - #{Time.zone.now}] There was an error processing MAAT ID #{maat_id}: #{e.message}."
        errored_maat_ids << { maat_id:, error: e.message }

        puts "[INFO - #{Time.zone.now}] Skipping MAAT ID #{maat_id}."
        next
      end

      puts "[INFO - #{Time.zone.now}] Successfully processed MAAT ID #{maat_id}."
      processed_maat_ids << maat_id

      sleep 12
    end

    puts "\n\n"
    puts "Processed the following #{processed_maat_ids.count} MAAT IDs:"
    pp processed_maat_ids

    puts "\n\n"

    puts "The following #{errored_maat_ids.count} MAAT IDs could not be processed: "
    pp errored_maat_ids
  end
end
