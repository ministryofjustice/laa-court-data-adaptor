# frozen_string_literal: true

class AddEventsToHearing < ActiveRecord::Migration[6.0]
  def change
    change_column_null :hearings, :body, true
    add_column :hearings, :events, :jsonb
  end
end
