class AddLocationToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :location, :string
  end
end
