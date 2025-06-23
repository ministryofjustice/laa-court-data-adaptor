namespace :db do
  desc "Generate views to highlight defendants with multiple MAATs"
  task highlight_multiple_maats: :environment do
    MultipleMaatAnalysisWorker.perform_async
    puts "Analysis initiated. Data will appear in file 'records_with_multiple_maats.txt'"
    puts "This file can be retrieve by a `kubectl cp` command."
  end
end
