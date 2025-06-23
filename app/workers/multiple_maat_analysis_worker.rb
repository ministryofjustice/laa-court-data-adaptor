# frozen_string_literal: true

class MultipleMaatAnalysisWorker
  include Sidekiq::Worker

  def perform
    execute_script :create_views
    data = execute_script :query

    File.open(Rails.root.join("records_with_multiple_maats.txt"), "w") do |file|
      file.write(data.first.keys.join("|"))
      file.write "\n"
      data.each do |row_with_issue|
        file.write(row_with_issue.values.join("|"))
        file.write "\n"
      end
    end

    execute_script :delete_views
  end

private

  def execute_script(script_name)
    raise "Unknown script" unless script_name.in?(%i[create_views query delete_views])

    sql_script = File.read(Rails.root.join("db/tasks/highlight_multiple_maats/#{script_name}.sql"))
    ActiveRecord::Base.connection.execute(sql_script).to_a
  end
end
