# frozen_string_literal: true

class AddUserNameToLaaReference < ActiveRecord::Migration[6.0]
  def change
    change_table :laa_references, bulk: true do |t|
      t.string :user_name, null: false, default: 'cpUser'
    end
    change_column_default :laa_references, :user_name, from: 'cpUser', to: nil
  end
end
