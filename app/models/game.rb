# frozen_string_literal: true

class Game < ApplicationRecord
  belongs_to :round

  belongs_to :team_1, class_name: "Team", foreign_key: "team_1_id", optional: true
  belongs_to :team_2, class_name: "Team", foreign_key: "team_2_id", optional: true

  has_many :stats, dependent: :destroy
  has_many :trophies, dependent: :destroy
end
