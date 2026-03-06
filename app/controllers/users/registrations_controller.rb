# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # Redirect after sign up based on pending invitation
  def after_sign_up_path_for(resource)
    # Check if there's a pending invitation token in session
    token = session.delete(:team_invitation_token)
    if token.present?
      # Validate the token still exists and hasn't expired
      invitation = TeamInvitation.find_valid_by_token(token)
      if invitation.present?
        # Redirect to team edit/update with token so they can complete the flow
        edit_team_path(invitation.team_id, token: token)
      else
        # Token expired or invalid during signup
        super
      end
    else
      super
    end
  end
end
