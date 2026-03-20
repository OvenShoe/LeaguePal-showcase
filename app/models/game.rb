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

  private

  def score_for_team(team)
    return 0 unless team

    user_ids = team.team_members.pluck(:user_id)
    return 0 if user_ids.empty?

    stats.where(label: "goals", user_id: user_ids).sum(:value)
  end
end
