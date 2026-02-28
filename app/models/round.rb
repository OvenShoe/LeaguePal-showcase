# frozen_string_literal: true

class Round < ApplicationRecord
  belongs_to :competition
  has_many :games, dependent: :destroy
end
