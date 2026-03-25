# frozen_string_literal: true

class Competition < ApplicationRecord
    # Returns a hash: { "goals" => { team: team, value: total }, ... } for each stat label
    def top_team_per_stat
      result = {}
      teams.each do |team|
        team.stats_summary.each do |label, value|
          if result[label].nil? || value > result[label][:value]
            result[label] = { team: team, value: value }
          end
        end
      end
      result
    end
  enum :sport, { unassigned: 0, Netball: 1, Football: 2 }, default: :unassigned
  validates :sport, presence: true
  belongs_to :competition_admin
  has_many :rounds, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :games, through: :rounds
  # validates :status, presence: true

  def top_stat_per_label
    # Collect all relevant stats for games in this competition
    stat_labels = games.first&.labels&.map(&:to_s) || []
    stats = Stat.joins(game: :round)
                .where(games: { round_id: rounds.ids }, label: stat_labels)
                .includes(:user)
                .order(value: :desc, created_at: :asc)

    stats.group_by(&:label).transform_values(&:first)
  end

  # Optional: for ties
  def top_stats_per_label_with_ties
    stat_labels = games.first&.labels&.map(&:to_s) || []
    stats = Stat.joins(game: :round)
                .where(games: { round_id: rounds.ids }, label: stat_labels)
                .includes(:user)
    grouped = stats.group_by(&:label)
    grouped.transform_values do |label_rows|
      max = label_rows.map(&:value).compact.max
      next [] if max.nil?
      label_rows.select { |s| s.value == max }
    end
  end
end
