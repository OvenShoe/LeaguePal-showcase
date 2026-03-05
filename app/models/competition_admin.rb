# frozen_string_literal: true

class CompetitionAdmin < ApplicationRecord
  belongs_to :user
  has_many :competitions, dependent: :nullify
end
