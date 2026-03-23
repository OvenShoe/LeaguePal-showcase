class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def avatar
    @user = User.find(params[:id])
  end

  def generate_ai_avatar
    team = Team.find(params[:team_id])
    generator = AiAvatarGenerator.new(current_user, team)
    generator.generate!

    redirect_to team_path(team), notice: "AI avatar generated!"
  rescue => e
    redirect_to team_path(team), alert: "Failed to generate avatar: #{e.message}"
  end

  def set_avatar
    avatar = current_user.ai_avatars.find(params[:id])

    current_user.avatar.attach(avatar.blob)

    redirect_to edit_user_registration_path, notice: "Profile picture updated!"
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
    @users = User.all
  end

  def next_match
    @user = User.find(params[:id])
    @next_match = @user.next_match
  end

  private

  def user_params
    params.require(:user).permit(:avatar, :first_name, :last_name, :email)
  end
end
