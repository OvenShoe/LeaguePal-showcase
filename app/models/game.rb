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
    # Return true if team_1_id is present and team_2_id is nil
    (self.team_1_id.present? && self.team_2_id.nil?) || (self.team_1_id.nil? && self.team_2_id.present?)
  end

  def empty?
    self.team_1_id.nil? && self.team_2_id.nil?
  end
end
