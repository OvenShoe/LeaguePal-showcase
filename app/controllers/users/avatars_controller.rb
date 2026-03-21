class Users::AvatarsController < ApplicationController
  before_action :authenticate_user!

  def generate
    team = Team.find(params[:id])

    unless team.users.include?(current_user)
      redirect_to edit_user_registration_path, alert: "You are not a member of this team." and return
    end

    blob = AiAvatarGenerator.new(current_user, team).generate!
    redirect_back fallback_location: edit_user_registration_path,
                  notice: "#{team.name} avatar generated!"
  rescue => e
    redirect_back fallback_location: edit_user_registration_path,
                  alert: "Failed: #{e.message}"
  end

  def set
    blob = ActiveStorage::Blob.find(params[:id])
    current_user.avatar.attach(blob)
    redirect_to edit_user_registration_path, notice: "Avatar updated."
  end

  def destroy
    blob = ActiveStorage::Blob.find(params[:id])
    TeamAvatar.find_by(blob: blob)&.destroy
    blob.purge
    redirect_to edit_user_registration_path, notice: "Avatar deleted."
  end
end
