class AddDefaultsToTeamsStats < ActiveRecord::Migration[7.0]
  def change
    change_column_default :teams, :draws, 0
    change_column_default :teams, :competition_points, 0
    change_column_default :teams, :games_played, 0
    change_column_default :teams, :losses, 0
    change_column_default :teams, :points_for, 0
    change_column_default :teams, :points_against, 0
    change_column_default :teams, :wins, 0
  end
end
