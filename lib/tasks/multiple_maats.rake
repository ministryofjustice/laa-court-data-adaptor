namespace :db do
  desc "Generate views to highlight defendants with multiple MAATs"
  task highlight_multiple_maats: :environment do
    execute_script = lambda do |script_name|
      sql_script = File.read(Rails.root.join("db/tasks/highlight_multiple_maats/#{script_name}.sql"))
      ActiveRecord::Base.connection.execute sql_script
    end

    execute_script.call("create_views")
    data = execute_script.call("query").to_a
    puts "=============================================="
    puts "Total defendant records affected: #{data.first['total']}"
    puts "=============================================="

    # puts data.first.keys.join("|")
    # data.each do |match|
    #   puts match.values.join("|")
    # end
    execute_script.call("delete_views")
  end
end
