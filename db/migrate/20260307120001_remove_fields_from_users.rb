class RemoveFieldsFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :role, :string
    remove_column :users, :team_position, :string
    remove_column :users, :thumbnail, :string
  end
end
