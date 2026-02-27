class ChangeFormColumnInTeams < ActiveRecord::Migration[8.1]
  def change
    execute 'ALTER TABLE teams ALTER COLUMN form TYPE varchar[] USING form::varchar[]'
    change_column_default :teams, :form, []
  end
end
