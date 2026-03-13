class AddStatusToTeamInivitations < ActiveRecord::Migration[8.1]
  def change
    add_column :team_invitations, :status, :integer, default: 0, null: false
  end
end
