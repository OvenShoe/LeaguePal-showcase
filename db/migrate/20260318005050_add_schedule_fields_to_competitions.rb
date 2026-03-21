class AddScheduleFieldsToCompetitions < ActiveRecord::Migration[8.1]
  def change
    add_column :competitions, :game_days, :integer, array: true, default: [], null: false
    add_column :competitions, :start_times, :string, array: true, default: [], null: false
    add_column :competitions, :locations, :string, array: true, default: [], null: false
  end
end
