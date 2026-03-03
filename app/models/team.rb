class Team < ApplicationRecord
    has_many :users
    has_many :trophies
    belongs_to :competition
end
