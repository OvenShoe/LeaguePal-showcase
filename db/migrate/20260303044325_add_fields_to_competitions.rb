class AddFieldsToCompetitions < ActiveRecord::Migration[8.1]
  def change
    add_column :competitions, :start_date, :datetime
    add_column :competitions, :end_date, :datetime
  end
end
