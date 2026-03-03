class Competition < ApplicationRecord
  has_many :teams
  belongs_to :competition_admin
end
