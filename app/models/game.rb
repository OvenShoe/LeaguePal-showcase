# frozen_string_literal: true

class Game < ApplicationRecord
  enum :bye, { false: 0, true: 1 }, default: :false

  belongs_to :round

  belongs_to :team_1, class_name: "Team", foreign_key: "team_1_id", optional: true
  belongs_to :team_2, class_name: "Team", foreign_key: "team_2_id", optional: true

  has_many :stats, dependent: :destroy
  has_many :trophies, dependent: :destroy

  def has_teams?
   self.team_1_id.present? && self.team_2_id.present?
  end

  def team_1_present?
    self.team_1_id.present?
  end

  def team_2_present?
    self.team_2_id.present?
  end

  def bye?
    team_1_id.present? ^ team_2_id.present?
  end

  def empty?
    self.team_1_id.nil? && self.team_2_id.nil?
  end

  def team_1_score
    score_for_team(team_1)
  end

  def team_2_score
    score_for_team(team_2)
  end

  def labels
    sport = self.round.competition.sport
    case sport
    when "Netball"
      %i[goals assists intercepts deflections turnovers center_passes rebounds]
    when "Football"
      %i[goals assists shots tackles dribbles duels_won saves yellow_cards red_cards possession]
    # when "Rugby"
    #   %i[tries conversions penalties tackles lineouts scrums yellow_cards red_cards]
    # when "Basketball"
    #   %i[3pointers field_goals slam_dunks free_throws points rebounds assists steals blocks turnovers fouls]
    # when "AFL"
    #   %i[goals behinds kicks handballs marks tackles hitouts disposals]
    # when "Cricket"
    #   %i[runs wickets catches run_outs stumpings maidens wides no_balls]
    # when "Tennis"
    #   %i[aces double_faults first_serve_percentage winners unforced_errors break_points_won games_won sets_won]
    else
      %i[]
    end
  end

  def top_stat_per_label
    rows = stats
             .where(label: labels.map(&:to_s))
             .includes(:user)
             .order(value: :desc, created_at: :asc)

    rows.group_by(&:label).transform_values(&:first)
  end

  def top_stats_per_label_with_ties
    rows = stats.where(label: labels.map(&:to_s)).includes(:user)
    grouped = rows.group_by(&:label)

    grouped.transform_values do |label_rows|
      max = label_rows.map(&:value).compact.max
      next [] if max.nil?

      label_rows.select { |s| s.value == max }
    end
  end

  private

  def score_for_team(team)
    return 0 unless team

    user_ids = team.team_members.pluck(:user_id)
    return 0 if user_ids.empty?

    stats.where(label: "goals", user_id: user_ids).sum(:value)
  end
end
