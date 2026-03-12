class RenameScaffoldStatusToScaffoldGeneratedInCompetitions < ActiveRecord::Migration[8.1]
  def change
    rename_column :competitions, :scaffold_status, :scaffold_generated
  end
end
