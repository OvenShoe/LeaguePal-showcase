<<<<<<< HEAD
class Competition < ApplicationRecord
  has_many :teams
  belongs_to :competition_admin
=======
# frozen_string_literal: true

class Competition < ApplicationRecord
  enum status: { Netball: 0, Basketball: 1, Football: 2, Rugby: 3, AFL: 4, Cricket: 5, Tennis: 6 }

  belongs_to :competition_admin
  has_many :rounds, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :games, through: :rounds

  validates :status, presence: true
>>>>>>> ed0ca7587ef956471e3980123e6ef21b15f7fd93
end
