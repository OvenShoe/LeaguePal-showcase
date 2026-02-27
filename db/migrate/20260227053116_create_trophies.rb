class CreateTrophies < ActiveRecord::Migration[8.1]
  def change
    create_table :trophies do |t|
      t.references :team_member, null: false, foreign_key: true
      t.integer :trophy_type

      t.timestamps
    end
  end
end
