class TeamInvitationsController < ApplicationController
 skip_before_action :authenticate_user!, only: [ :home ]
  def accept
    token = params[:token]
    invitation = TeamInvitation.find_by(token: token)

    if invitation.nil?
      redirect_to root_path, alert: "Invalid invitation token."
      return
    end

    team = invitation.team
    user = current_user

    if team.users.include?(user)
      redirect_to team_path(team), notice: "You are already a member of this team."
      return
    end

    team.users << user
    invitation.destroy

    redirect_to team_path(team), notice: "You have successfully joined the team!"
  end
end
