class CreateStats < ActiveRecord::Migration[8.1]
  def change
    create_table :stats do |t|
      t.references :game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
