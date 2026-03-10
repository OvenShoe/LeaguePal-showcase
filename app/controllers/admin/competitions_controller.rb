class Admin::CompetitionsController < ApplicationController
  before_action :set_competition, only: %i[ show edit update send_invite ]

  def index
    @competitions = Competition.all
  end

  def show
    @teams = @competition.teams
  end

  def new
    @competition = Competition.new(sport: "unassigned")
  end

  def create
    competition_admin = current_user.competition_admins.first_or_create!
    @competition = competition_admin.competitions.new(competition_params)
    if @competition.save
      redirect_to admin_competition_path(@competition)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @competition.update(competition_params)
      redirect_to admin_competition_path(@competition)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def send_invite
    @team = Team.new(name: team_invitation_params[:name], competition: @competition)

    if @team.save
      invitation, raw_token = TeamInvitation.create_with_token!(
        team: @team,
        invitee_email: team_invitation_params[:invitee_email],
        inviter: current_user,
        role: team_invitation_params[:role].presence || :captain
      )

      TeamInvitationMailer.invite_email(invitation, raw_token).deliver_later
      redirect_to admin_competition_path(@competition), notice: "Team invitation sent successfully!"
    else
      redirect_to admin_competition_path(@competition), alert: "Failed to create team: #{@team.errors.full_messages.join(', ')}"
    end
  rescue StandardError => e
    @team&.destroy if @team&.persisted?
    redirect_to admin_competition_path(@competition), alert: "Failed to send invitation: #{e.message}"
  end

  private

  def set_competition
    @competition = Competition.find(params[:id])
  end

  def team_invitation_params
    params.require(:team_invite).permit(:name, :invitee_email, :role)
  end

  def competition_params
    params.require(:competition).permit(:name, :sport, :start_date, :end_date)
  end
end
