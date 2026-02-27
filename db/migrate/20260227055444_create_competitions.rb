class CreateCompetitions < ActiveRecord::Migration[8.1]
  def change
    create_table :competitions do |t|
      t.references :competition_admin, null: false, foreign_key: true

      t.timestamps
    end
  end
end
