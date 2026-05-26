namespace :hearings do
  desc "Fetch past hearings from HMCTS Common Platform for MAAT IDs listed in a CSV file (one per row, no header). \
        Example: rake 'hearings:fetch[path/to/maat_ids.csv]'"
  task :fetch, [:csv_path] => :environment do |_task, args|
    require "csv"
    maat_ids = CSV.read(args[:csv_path]).flatten.map(&:strip)

    puts "[INFO - #{Time.zone.now}] Scheduling #{maat_ids.count} MAAT IDs ..."

    maat_ids.each_with_index do |maat_id, i|
      MaatIdHearingFetcherWorker.perform_in(i * 12.seconds, maat_id)
    end

    total_hours = (maat_ids.count * 12.0 / 3600).round(1)
    puts "[INFO - #{Time.zone.now}] All jobs enqueued. Expected completion in ~#{total_hours}h."
  end
end
