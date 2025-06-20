class AddUnlinkReasonCodeToLaaReferences < ActiveRecord::Migration[8.0]
  def change
    add_column :laa_references, :unlink_reason_code, :integer
  end
end
