class AddStartTimeToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :start_time, :datetime
  end
end
