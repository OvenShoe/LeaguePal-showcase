class ChangeCompleteNullOnGames < ActiveRecord::Migration[8.1]
  def change
    change_column_null :games, :complete, false, false
  end
end
