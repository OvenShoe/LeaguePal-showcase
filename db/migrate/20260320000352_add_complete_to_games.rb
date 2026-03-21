class AddCompleteToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :complete, :boolean, default: false
  end
end
