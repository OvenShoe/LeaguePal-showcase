class AvatarsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    avatar = current_user.ai_avatars.find(params[:id])
    avatar.purge
    redirect_to edit_user_registration_path, notice: "Avatar deleted."
  end
end
