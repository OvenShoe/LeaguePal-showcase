class TeamInvitationMailer < ApplicationMailer
  def invite_email(invitation, raw_token)
    @inviter = invitation.inviter
    @team    = invitation.team
    @role    = invitation.role
    @token   = raw_token

    if @role == "captain"
      @invite_url = Rails.application.routes.url_helpers.edit_team_url(
        @team,
        token: @token,
        **url_options
      )
    else
      @invite_url = Rails.application.routes.url_helpers.team_url(
        @team,
        token: @token,
        **url_options
      )
    end



    mail(
      to: invitation.invitee_email,
      subject: "You've been invited to join team id:#{@team.id} on LeaguePal!"
    )
  end

  private

  def url_options
    {
      host: host_opts[:host],
      port: host_opts[:port]
    }
  end

  def host_opts
    @host_opts ||= Rails.application.config.action_mailer.default_url_options || { host: "localhost", port: 3000 }
  end
end
