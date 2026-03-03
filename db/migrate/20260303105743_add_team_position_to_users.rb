class AddTeamPositionToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :team_position, :string
  end
end
