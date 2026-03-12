class AddScaffoldStatusToCompetitions < ActiveRecord::Migration[8.1]
  def change
    add_column :competitions, :scaffold_status, :boolean, default: false, null: false
  end
end
