class AddReferencesToTeamMembers < ActiveRecord::Migration[8.1]
  def change
    add_reference :team_members, :user, null: false, foreign_key: true
    add_reference :team_members, :team, null: false, foreign_key: true
  end
end
