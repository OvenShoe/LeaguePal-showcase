class AddSportToCompetitions < ActiveRecord::Migration[8.1]
  def change
    add_column :competitions, :sport, :integer, default: 0, null: false
  end
end
