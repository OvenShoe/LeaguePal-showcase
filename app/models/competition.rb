# frozen_string_literal: true

class Competition < ApplicationRecord
  enum :sport, { unassigned: 0, Netball: 1, Football: 2 }, default: :unassigned
  validates :sport, presence: true
  belongs_to :competition_admin
  has_many :rounds, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :games, through: :rounds
  # validates :status, presence: true
end
