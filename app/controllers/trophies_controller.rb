class TrophiesController < ApplicationController
  def index
    @trophies = current_user.trophies
  end

  def new
    @trophy = Trophy.new
  end

  def create
    @trophy = Trophy.new(trophy_params)
    if @trophy.save
      redirect_to trophies_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def trophy_params
    params.require(:trophy).permit(:user_id, :team_id, :name, :description)
  end
end
