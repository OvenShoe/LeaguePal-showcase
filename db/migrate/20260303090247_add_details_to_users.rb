class AddDetailsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :last_name, :string
    add_column :users, :date_of_birth, :date
    add_column :users, :role, :string
  end
end
