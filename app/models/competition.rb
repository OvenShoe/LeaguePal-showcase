# frozen_string_literal: true

class Competition < ApplicationRecord
  enum :status, { unassigned: 0, Basketball: 1, Football: 2, Rugby: 3, AFL: 4, Cricket: 5, Tennis: 6, netball: 7 }, default: :unassigned
  belongs_to :competition_admin
  has_many :rounds, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :games, through: :rounds

  validates :status, presence: true
end
