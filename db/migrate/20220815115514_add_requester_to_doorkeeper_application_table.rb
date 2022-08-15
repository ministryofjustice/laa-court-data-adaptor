class AddRequesterToDoorkeeperApplicationTable < ActiveRecord::Migration[6.1]
  def change
    add_column :oauth_applications, :requester, :string, null: false, :default => ""
  end
end
