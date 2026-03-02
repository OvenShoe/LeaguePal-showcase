class RemoveTeamIdFromUser < ActiveRecord::Migration[8.1]
  def change
    remove_reference :users, :team, null: false, foreign_key: true
  end
end
