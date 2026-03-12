class ChangeByeNullInGames < ActiveRecord::Migration[8.1]
  def change
    change_column_null :games, :bye, false, false  # (table, column, null, default_for_existing_rows)
  end
end
