# frozen_string_literal: true

class TeamInvitation < ApplicationRecord
  require "securerandom"

  belongs_to :team
  belongs_to :inviter, class_name: "User"

  enum :role, { player: 0, captain: 1 }

  validates :invitee_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token_digest, presence: true
  validates :role, presence: true

  before_validation :ensure_token_digest, on: :create
  before_create :set_default_expires_at

  # Create an invitation and return the record plus the raw token
  # Example:
  #   invitation, raw_token = TeamInvitation.create_with_token!(inviter: user, team: team, invitee_email: 'a@b.com', role: :player)
  def self.create_with_token!(inviter:, team:, invitee_email:, role: :player, expires_at: 7.days.from_now)
    role = role.presence || :player
    raw_token = SecureRandom.urlsafe_base64(24)
    token_digest = BCrypt::Password.create(raw_token)

    invitation = create!(
      inviter: inviter,
      team: team,
      invitee_email: invitee_email.to_s.downcase,
      token_digest: token_digest,
      role: role,
      expires_at: expires_at
    )

    [ invitation, raw_token ]
  end

  # Accept the invitation and create the team membership for the provided user
  def accept!(user)
    transaction do
      update!(accepted_at: Time.current)
      TeamMember.create!(team: team, user: user, role: self.role)
    end
  end

  def expired?
    expires_at.present? && Time.current > expires_at
  end

  def accepted?
    accepted_at.present?
  end

  # Compare a raw token to this invitation's digest
  def valid_token?(raw_token)
    return false if token_digest.blank?
    BCrypt::Password.new(token_digest) == raw_token
  end

  # Find an outstanding, not-expired invitation matching the provided raw token
  # Note: this performs a scan over outstanding invitations; that's fine for
  # typical low-volume invite use-cases. If you expect high volume, consider
  # storing a searchable token or splitting the digest.
  def self.find_valid_by_token(raw_token)
    where(accepted_at: nil).where("expires_at IS NULL OR expires_at > ?", Time.current).find do |inv|
      inv.valid_token?(raw_token)
    end
  end

  private

  def ensure_token_digest
    return if token_digest.present?
    raw = SecureRandom.urlsafe_base64(24)
    self.token_digest = BCrypt::Password.create(raw)
  end

  def set_default_expires_at
    self.expires_at ||= 7.days.from_now
  end
end
