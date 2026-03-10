class AddNameToCompetitions < ActiveRecord::Migration[8.1]
  def change
    add_column :competitions, :name, :string
  end
end
