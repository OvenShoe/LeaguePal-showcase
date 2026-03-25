# frozen_string_literal: true

class Team < ApplicationRecord
  # Returns an array of last 5 results: 'W', 'L', or 'D'
  belongs_to :competition

  has_one_attached :logo
  has_one_attached :jersey

  has_many :team_members, dependent: :destroy
  has_many :team_invitations, dependent: :destroy
  has_many :users, through: :team_members
  has_many :team_avatars

  has_many :games_as_team_1, class_name: "Game", foreign_key: "team_1_id"
  has_many :games_as_team_2, class_name: "Game", foreign_key: "team_2_id"

      def form
        all_games = (games_as_team_1 + games_as_team_2)
          .select { |g| g.start_time.present? && g.respond_to?(:complete) && g.complete }
          .sort_by(&:start_time)
          .last(5)
        all_games.map do |game|
          next unless game.team_1_id && game.team_2_id
          team_score = if game.team_1_id == id
            game.team_1_score
          else
            game.team_2_score
          end
          opponent_score = if game.team_1_id == id
            game.team_2_score
          else
            game.team_1_score
          end
          if team_score.nil? || opponent_score.nil?
            nil
          elsif team_score > opponent_score
            "W"
          elsif team_score < opponent_score
            "L"
          else
            "D"
          end
        end.compact
      end
    # Returns a hash of stat labels and their total values for this team
    def stats_summary
      user_ids = team_members.pluck(:user_id)
      Stat.where(user_id: user_ids)
          .group(:label)
          .sum(:value)
    end

  def next_game
    next_game = self.competition.games
      .where("(team_1_id = :id OR team_2_id = :id) AND start_time >= :now", id: id, now: Time.current)
      .order(:start_time)
      .first
    next_game.present? ? next_game : nil
  end
end
