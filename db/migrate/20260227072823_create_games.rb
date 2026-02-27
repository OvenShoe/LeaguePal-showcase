class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.bigint :team_1_id
      t.bigint :team_2_id

      t.timestamps
    end
  end
end
