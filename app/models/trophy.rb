<<<<<<< HEAD
class Trophy < ApplicationRecord
  belongs_to :user
  belongs_to :team
=======
# frozen_string_literal: true

class Trophy < ApplicationRecord
  belongs_to :game
  belongs_to :team_member
>>>>>>> ed0ca7587ef956471e3980123e6ef21b15f7fd93
end
