namespace :db do
  desc "Generate views to highlight defendants with multiple MAATs"
  task highlight_multiple_maats: :environment do
    MultipleMaatAnalysisWorker.perform_async
    puts "Analysis scheduled. Data will appear in file 'tmp/records_with_multiple_maats.txt'"
    puts "This file can be retrieved with: `kubectl cp -n <environment> <worker-pod-id>:tmp/records_with_multiple_maats.txt records_with_multiple_maats.txt"
  end
end
