class AddRoleToTeamInvitations < ActiveRecord::Migration[8.0]
  def change
    add_column :team_invitations, :role, :integer, default: 0, null: false
    add_index :team_invitations, :role
  end
end
