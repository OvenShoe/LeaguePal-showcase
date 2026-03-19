class RemoveDefaultFromCompetitionSport < ActiveRecord::Migration[8.1]
  def up
    change_column_default :competitions, :sport, from: 0, to: nil
  end

  def down
    change_column_default :competitions, :sport, from: nil, to: 0
  end
end
