class AddUnlinkOtherReasonTextToLaaReference < ActiveRecord::Migration[8.0]
  def change
    add_column :laa_references, :unlink_other_reason_text, :text
  end
end
