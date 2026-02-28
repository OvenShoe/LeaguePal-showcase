class UsersController < ApplicationController
  def show
    @users = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def index
    @user = User.all
  end

  def next_match
    @user = User.find(params[:id])
    @next.match = @user.next_match
  end

  private

  def user_params
    params.require(:user).permit(:thumbnail)
  end
end
