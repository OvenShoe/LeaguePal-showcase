class CompetitionsController < ApplicationController
  before_action :set_competition, only: %i[ show edit update ]

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
      render :new, status: :unprocessable_entity
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
