class AddReferenceToTeams < ActiveRecord::Migration[8.1]
  def change
    add_reference :teams, :competition, null: false, foreign_key: true
  end
end
