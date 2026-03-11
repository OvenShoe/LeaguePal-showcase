class TeamInvitationsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ accept reject ]
  before_action :set_token_and_invitation

  def accept
    check_invitation(@invitation)

    # Verify current user exists and matches invited email
    if current_user.nil?
      return render json: { error: "Please log in to accept the invitation." }, status: :unauthorized
    end

    if current_user.email != @invitation.invitee_email
      return render json: { error: "This invitation is not for you." }, status: :forbidden
    end

    # Use the model's accept! method which handles both status update and TeamMember creation
    @invitation.accept!(current_user)
    render json: { success: true, redirect_url: team_path(@invitation.team), message: "You have successfully joined the team!" }, status: :ok
  rescue StandardError => e
    render json: { error: "Error accepting invitation: #{e.message}" }, status: :unprocessable_entity
  end

  def reject
    check_invitation(@invitation)

    @team = @invitation.team
    @invitation.update!(status: "rejected")
    render json: { success: true, redirect_url: root_path, message: "Rejected invitation to #{@team.name}" }, status: :ok
  end

  private

  def check_invitation(invitation)
    if invitation.nil?
      render json: { error: "Invalid invitation token." }, status: :not_found and return
    elsif invitation.expired?
      render json: { error: "Invitation token has expired." }, status: :bad_request and return
    elsif invitation.accepted?
      render json: { error: "Invitation token has already been used." }, status: :conflict and return
    end
  end

  def set_token_and_invitation
    @token = params[:token]
    @invitation = TeamInvitation.find_valid_by_token(@token) if @token.present?
  end
end
