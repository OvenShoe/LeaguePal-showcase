class CompetitionsController < ApplicationController
  require "bcrypt"
  require "securerandom"

  before_action :set_competition, only: %i[ show edit update send_invite]

  def index
    @competitions = Competition.all
  end

  def show
  end

  def new
    @competition = Competition.new
  end

  def create
    @competition = Competition.new(competition_params)
    if @competition.save
      redirect_to @competition
    else
      render :new
    end
  end

  def send_invite
    # Create a new team with team_name params and send id to team_invite
    @team = Team.new(name: team_invitation_params[:name], competition: @competition)
    # Create a new team invitations
    if @team.save
    invitation, raw_token = TeamInvitation.create_with_token!(
        team: @team,
        invitee_email: team_invitation_params[:invitee_email],
        inviter: current_user,
      )

      # Send invitation email
      TeamInvitationMailer.invite_email(invitation, raw_token).deliver_later
      redirect_to admin_competition_path(@competition), notice: "Team invitation sent successfully!"
    else
      redirect_to admin_competition_path(@competition), alert: "Failed to create team: #{@team.errors.full_messages.join(', ')}"
    end
  end

  def edit
  end

  def update
    if @competition.update(competition_params)
      redirect_to @competition
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def team_invitation_params
    params.require(:team_invite).permit(:name, :invitee_email, :user_id)
  end

  def set_competition
    @competition = Competition.find(params[:id])
  end

  def competition_params
    params.require(:competition).permit(:name, :start_date, :end_date)
  end
end
