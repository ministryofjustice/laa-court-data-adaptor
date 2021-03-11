class RemoveDummyMaatReferenceFromLaaReferences < ActiveRecord::Migration[6.1]
  def change
    remove_column :laa_references, :dummy_maat_reference, :boolean, default: false
  end
end
