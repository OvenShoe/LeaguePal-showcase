class CompetitionsController < ApplicationController
  require "bcrypt"
  require "securerandom"

  before_action :set_competition, only: %i[ show edit update ]

  def index
    # All user competitions
    # @competitions = Competition.all
    @competitions = Competition.joins(:teams).where(teams: { id: current_user.teams.select(:id) }).distinct
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
