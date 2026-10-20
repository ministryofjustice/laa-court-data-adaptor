namespace :laa_references do
  desc "Set court_application_id on existing court application links. Dry run unless APPLY=true.
        Example: rake laa_references:backfill_court_application_id APPLY=true"
  task backfill_court_application_id: :environment do
    apply = ENV["APPLY"] == "true"

    puts "[INFO - #{Time.zone.now}] Backfilling court_application_id on LAA references (#{apply ? 'APPLY' : 'DRY RUN'})..."

    result = CourtApplicationLaaReferenceBackfiller.call(apply:)

    puts "[INFO - #{Time.zone.now}] #{apply ? 'Updated' : 'Would update'} #{result[:to_update].size} LAA reference(s), " \
         "MAAT references: #{result[:to_update].join(', ')}"
    puts "[INFO - #{Time.zone.now}] Skipped #{result[:skipped].size} LAA reference(s) (subject id is also a prosecution case defendant id), " \
         "MAAT references: #{result[:skipped].join(', ')}"
  end
end
