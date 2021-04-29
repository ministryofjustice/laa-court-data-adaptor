class CreateFeatureFlags < ActiveRecord::Migration[6.1]
  def change
    create_table :feature_flags do |t|
      t.string :name
      t.boolean :enabled

      t.timestamps
    end

    add_index :feature_flags, :name, unique: true
  end
end
