class DropIncomingPayloadTable < ActiveRecord::Migration[8.0]
  def up
    drop_table :incoming_payloads
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
