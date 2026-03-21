class CreateTeamAvatars < ActiveRecord::Migration[8.1]
  def change
    create_table :team_avatars do |t|
      t.references :user, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.bigint :blob_id, null: false
      t.timestamps
    end
    add_foreign_key :team_avatars, :active_storage_blobs, column: :blob_id
    add_index :team_avatars, [:user_id, :team_id]
  end
end
