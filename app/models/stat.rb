# frozen_string_literal: true

class Stat < ApplicationRecord
  belongs_to :game
  belongs_to :user
end
