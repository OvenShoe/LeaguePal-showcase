class CompetitionAdmin < ApplicationRecord
 belongs_to :user
 has_many :competitions
end
