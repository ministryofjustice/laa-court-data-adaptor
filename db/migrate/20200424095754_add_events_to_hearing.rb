# frozen_string_literal: true

class AddEventsToHearing < ActiveRecord::Migration[6.0]
  # rubocop:disable Rails/BulkChangeTable
  def change
    change_column_null :hearings, :body, true
    add_column :hearings, :events, :jsonb
  end
  # rubocop:enable Rails/BulkChangeTable
end
