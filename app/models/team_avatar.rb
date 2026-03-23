class TeamAvatar < ApplicationRecord
  belongs_to :user
  belongs_to :team
  belongs_to :blob, class_name: "ActiveStorage::Blob", foreign_key: :blob_id

  MAX_PER_TEAM = 8

  def self.enforce_limit!(user, team)
    records = where(user: user, team: team).order(created_at: :asc)
    if records.count >= MAX_PER_TEAM
      oldest = records.first
      oldest.blob.purge
      oldest.destroy
    end
  end
end
