# frozen_string_literal: true

class TeamMember < ApplicationRecord
  enum :role, { player: 0, captain: 1 }
  belongs_to :team
  belongs_to :user

  has_many :trophies, dependent: :nullify
  def list_name
    "#{self.user.first_name} #{self.user.last_name} - #{self.team.name}"
  end
end
