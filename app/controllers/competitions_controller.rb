class CompetitionsController < ApplicationController
  require "bcrypt"
  require "securerandom"

  before_action :set_competition, only: %i[ show edit update ]
  before_action :authenticate_user!
  def index
    return @competitions = Competition.none unless user_signed_in?

    team_ids = current_user.teams.select(:id)
    admin_ids = current_user.competition_admins.select(:id)

    @competitions = Competition
      .left_outer_joins(:teams)
      .where(teams: { id: team_ids })
      .or(Competition.where(competition_admin_id: admin_ids)).distinct
  end

  def show
    @next_game = @competition.games.where("start_time >= ?", Time.current).order(:start_time).first
    @teams = @competition.teams
    @top_stats = @competition.top_stat_per_label
    # League standings partial
    # Reusable stats_helper partial
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

  def set_competition
    @competition = Competition.find(params[:id])
  end

  def competition_params
    params.require(:competition).permit(:name, :start_date, :end_date)
  end
end
