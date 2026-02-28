# frozen_string_literal: true

class TeamMember < ApplicationRecord
  belongs_to :team
  belongs_to :user

  has_many :trophies, dependent: :nullify
end
