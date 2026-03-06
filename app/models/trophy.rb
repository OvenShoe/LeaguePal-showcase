# frozen_string_literal: true

class Trophy < ApplicationRecord
  belongs_to :game
  belongs_to :team_member
end
