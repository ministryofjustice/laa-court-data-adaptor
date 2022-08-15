class AddRequesterToDoorkeeperApplicationTable < ActiveRecord::Migration[6.1]
  def change
    add_column :oauth_applications, :requester_email
  end
end
