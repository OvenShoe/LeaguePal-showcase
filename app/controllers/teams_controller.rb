class TeamsController < ApplicationController
  before_action :authenticate_user!, except: [ :edit ]
  before_action :set_team, only: %i[ edit update show add_member send_invite ]

  def index
    @competition = @team.competition
    @comp_teams = @competition.teams
  end

  def edit
    token = params[:token]
    if token.present?
      invitation = TeamInvitation.find_valid_by_token(token)

      if invitation.nil?
        redirect_to root_path, alert: "Invalid or expired invitation."
      elsif invitation.accepted?
        redirect_to root_path, alert: "This invitation has already been accepted."
      elsif !user_signed_in?
        # Redirect to sign up with token in params
        session[:team_invitation_token] = token
        redirect_to new_user_registration_path, notice: "Please create an account to accept this invitation."
      else
        # User is logged in and invitation is valid
        @team = invitation.team
        @invitation = invitation
        flash.now[:notice] = "Welcome! Please complete your profile before joining the team."
      end
    else
      authenticate_user! if !user_signed_in?
    end
  end

  def add_member
    @team_member = @team.team_members.build(team_member_params)
    @team_member.role = :player

    if @team_member.save

      redirect_to @team, notice: "User added to team"
    else
      redirect_to @team, alert: "Error adding user to team"
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to @team, alert: "Error adding user to team"
  end

  def send_invite
    invitation, raw_token = TeamInvitation.create_with_token!(
      team: @team,
      invitee_email: team_invitation_params[:invitee_email],
      inviter: current_user,
      role: :player
    )

    # Send invitation email
    TeamInvitationMailer.invite_email(invitation, raw_token).deliver_later
    redirect_to @team, notice: "Team invitation sent successfully!"
  rescue StandardError => e
    invitation&.destroy if defined?(invitation) && invitation&.persisted?
    redirect_to @team, alert: "Failed to send invitation: #{e.message}"
  end

  def update
    if @team.update(team_params)
      # Accept token if present in params or session
      token = params[:token] || session.delete(:team_invitation_token)
      if token.present?
        invitation = TeamInvitation.find_valid_by_token(token)
        invitation&.accept!(current_user)
        redirect_to @team, notice: "Team updated and invitation accepted!"
      else
        redirect_to @team, notice: "Team updated successfully"
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @users = User.all - [ current_user ]
    @team_members = @team.team_members.includes(:user)
    @team_member = @team.team_members.build
  end

  private
  def set_team
    @team = Team.find(params[:id])
  end

  def team_member_params
    params.require(:team_member).permit(:user_id)
  end

  def team_invitation_params
    params.require(:team_invitation).permit(:invitee_email)
  end

  def team_params
    params.require(:team).permit(:name, :user_id, :jersey)
  end
end
