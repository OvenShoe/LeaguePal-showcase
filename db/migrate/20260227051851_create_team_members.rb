class CreateTeamMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :team_members do |t|
      t.string :role

      t.timestamps
    end
  end
end
