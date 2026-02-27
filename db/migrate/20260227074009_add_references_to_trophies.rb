class AddReferencesToTrophies < ActiveRecord::Migration[8.1]
  def change
    add_reference :trophies, :game, null: false, foreign_key: true
  end
end
