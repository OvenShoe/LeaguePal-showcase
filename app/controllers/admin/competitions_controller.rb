class Admin::CompetitionsController < ApplicationController
  before_action :set_competition, only: %i[ show edit update ]

  def index
    @competitions = Competition.all
  end

  def show
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
      render :new, status: :unprocessable_entity
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

  private

  def set_competition
    @competition = Competition.find(params[:id])
  end

  def competition_params
    params.require(:competition).permit(:name, :sport, :start_date, :end_date)
  end
end
