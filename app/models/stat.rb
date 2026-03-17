# frozen_string_literal: true

class Stat < ApplicationRecord
  belongs_to :game
  belongs_to :user
  after_create_commit :broadcast_to_game


  def user_team
    # Find which team this user played for in this game
    team_1_members = game.team_1&.team_members&.pluck(:user_id) || []
    team_2_members = game.team_2&.team_members&.pluck(:user_id) || []

    if team_1_members.include?(user_id)
      game.team_1&.name
    elsif team_2_members.include?(user_id)
      game.team_2&.name
    else
      "Unknown team"
    end
  end

  private
    def broadcast_to_game
      broadcast_prepend_later_to(
        game,
        target: ActionView::RecordIdentifier.dom_id(game, :stats_list),
        partial: "stats/stat",
        locals: { stat: self }
      )
      broadcast_score_update
    end

    def broadcast_score_update
      team_1_user_ids = game.team_1&.team_members&.pluck(:user_id) || []
      team_2_user_ids = game.team_2&.team_members&.pluck(:user_id) || []

      team_1_score = game.stats.where(label: "goals", user_id: team_1_user_ids).sum(:value)
      team_2_score = game.stats.where(label: "goals", user_id: team_2_user_ids).sum(:value)

      broadcast_replace_later_to(
        game,
        target: "team_1_score",
        partial: "games/score",
        locals: { team_key: "team_1", score: team_1_score }
      )
      broadcast_replace_later_to(
        game,
        target: "team_2_score",
        partial: "games/score",
        locals: { team_key: "team_2", score: team_2_score }
      )
    end
end
