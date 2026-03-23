class AddTokenToTeamInvitations < ActiveRecord::Migration[8.1]
  def change
    add_column :team_invitations, :token, :string, null: false, default: ""
    add_index :team_invitations, :token, unique: true

    # Populate existing records with a placeholder (they won't be used since they're already accepted/rejected)
    # In production, you might want to handle this differently
    execute "UPDATE team_invitations SET token = '' WHERE token IS NULL"
    change_column :team_invitations, :token, :string, null: false
  end
end
