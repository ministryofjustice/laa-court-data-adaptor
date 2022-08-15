class AddRequesteeToDoorkeeperApplicationTable < ActiveRecord::Migration[6.1]
  def change
    add_column :oauth_applications, :requestee_email
  end
end
