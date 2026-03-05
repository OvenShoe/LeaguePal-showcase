class CreateTeamInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :team_invitations do |t|
      t.references :team, null: false, foreign_key: true
      t.references :inviter, null: false, foreign_key: { to_table: :users }
      t.string :invitee_email, null: false
      t.string :token_digest, null: false
      t.datetime :accepted_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :team_invitations, :invitee_email
    add_index :team_invitations, :token_digest, unique: true
  end
end
