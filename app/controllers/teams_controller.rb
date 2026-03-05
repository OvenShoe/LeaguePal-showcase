class TeamsController < ApplicationController
  before_action :authenticate_user!, except: [ :edit ]
  before_action :set_team, only: %i[ edit update show ]

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
    @team = Team.find(params[:id])
    user = User.find(team_params[:user_id])

    TeamMember.create!(team_id: @team.id, user_id: user.id, role: :player)

    redirect_to @team, notice: "User added to team"
  rescue ActiveRecord::RecordInvalid
    redirect_to @team, alert: "Error adding user to team"
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
  end

  private
  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :user_id, :jersey)
  end
end
