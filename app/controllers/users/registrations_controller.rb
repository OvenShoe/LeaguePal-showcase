# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Redirect after sign up based on pending invitation
  def after_sign_up_path_for(resource)
    # Check if there's a pending invitation token in session
    token = session.delete(:team_invitation_token)
    if token.present?
      # Validate the token still exists and hasn't expired
      invitation = TeamInvitation.find_valid_by_token(token)
      if invitation.present?
        # Redirect based on role
        # Captains go to edit to complete team setup, players go to show to see popup
        if invitation.role == "captain"
          edit_team_path(invitation.team_id, token: token)
        else
          team_path(invitation.team_id, token: token)
        end
      else
        # Token expired or invalid during signup
        super
      end
    else
      super
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name ])
  end
end
