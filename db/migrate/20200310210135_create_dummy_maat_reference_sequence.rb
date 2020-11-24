# frozen_string_literal: true

class CreateDummyMaatReferenceSequence < ActiveRecord::Migration[6.0]
  def up
    execute "CREATE SEQUENCE IF NOT EXISTS dummy_maat_reference_seq START 10000000;"
  end

  def down
    execute "DROP SEQUENCE IF EXISTS dummy_maat_reference_seq;"
  end
end
