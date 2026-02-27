class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |t|
      t.integer :wins
      t.integer :losses
      t.integer :draws
      t.integer :points_for
      t.integer :points_against
      t.integer :games_played
      t.string :form
      t.integer :competition_points

      t.timestamps
    end
  end
end
