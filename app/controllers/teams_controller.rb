class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[ edit update show ]

  def edit
    token = params[:token]
    if token.present?
      invitation = TeamInvitation.find_valid_by_token(token)

      if invitation.nil?
        redirect_to root_path, alert: "Invalid or expired invitation."
      elsif invitation.team_id != @team.id
        redirect_to root_path, alert: "This invitation is for a different team."
      elsif invitation.accepted?
        redirect_to root_path, alert: "This invitation has already been accepted."

      else
        # Pass conditon presumably an invitation is valid when reaching this stage
        # Store invitation in session or instance variable for use in update action
        @invitation = invitation
        # Optionally flash a welcome message
        flash.now[:notice] = "Welcome! Please complete your team profile."
      end
    end
  end

  def update
    if @team.update(team_params)
      # Accept token if it is present
      if params[:token].present?
        invitation = TeamInvitation.find_valid_by_token(params[:token])
        invitation&.accept!(current_user)
      end
      redirect_to @team, notice: "Team updated succesfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
  end

  private
  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
