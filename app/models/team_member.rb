# frozen_string_literal: true

class TeamMember < ApplicationRecord
  enum role: { player: 0, captain: 1 }
  belongs_to :team
  belongs_to :user

  has_many :trophies, dependent: :nullify
end
