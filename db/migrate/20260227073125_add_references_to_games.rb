class AddReferencesToGames < ActiveRecord::Migration[8.1]
  def change
    add_reference :games, :round, null: false, foreign_key: true

    # Add foreign keys to existing columns
    add_foreign_key :games, :teams, column: :team_1_id
    add_foreign_key :games, :teams, column: :team_2_id

    # Optionally, add indexes if not present
    add_index :games, :team_1_id unless index_exists?(:games, :team_1_id)
    add_index :games, :team_2_id unless index_exists?(:games, :team_2_id)
  end
end
