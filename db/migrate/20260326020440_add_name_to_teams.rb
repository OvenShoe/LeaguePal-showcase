class AddNameToTeams < ActiveRecord::Migration[8.1]
  def change
    add_column :teams, :name, :string
  end
end
