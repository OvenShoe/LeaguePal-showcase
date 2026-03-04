class TeamInvitationMailer < ApplicationMailer
  def invite_email(invitation, raw_token)
    @inviter = invitation.inviter
    @team    = invitation.team
    @token   = raw_token

    host_opts = Rails.application.config.action_mailer.default_url_options
    @invite_url = Rails.application.routes.url_helpers.new_team_url(
      token: @token,
      host: host_opts[:host],
      port: host_opts[:port]
    )

    mail(
      to: invite_email,
      subject: "You've been invited to join team id:#{@team.id} on LeaguePal!"
    )
  end
end
