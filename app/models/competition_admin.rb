<<<<<<< HEAD
class CompetitionAdmin < ApplicationRecord
 belongs_to :user
 has_many :competitions
=======
# frozen_string_literal: true

class CompetitionAdmin < ApplicationRecord
  belongs_to :user
  has_many :competitions, dependent: :nullify
>>>>>>> ed0ca7587ef956471e3980123e6ef21b15f7fd93
end
