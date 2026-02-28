# frozen_string_literal: true

class Team < ApplicationRecord
  belongs_to :competition

  has_one_attached :logo
  has_one_attached :jersey

  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members

  has_many :games_as_team_1, class_name: "Game", foreign_key: "team_1_id"
  has_many :games_as_team_2, class_name: "Game", foreign_key: "team_2_id"
end
