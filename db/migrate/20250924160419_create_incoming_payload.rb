class CreateIncomingPayload < ActiveRecord::Migration[8.0]
  def change
    create_table :incoming_payloads do |t|
      t.jsonb :body
      t.string :request_id
      t.string :payload_type
      t.string :identifier
      t.timestamps
    end
  end
end
