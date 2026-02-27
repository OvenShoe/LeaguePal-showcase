class CreateCompetitionAdmins < ActiveRecord::Migration[8.1]
  def change
    create_table :competition_admins do |t|
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
