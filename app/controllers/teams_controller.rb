class TeamsController < ApplicationController
  before_action :authenticate_user!, except: %i[ edit show ]
  before_action :set_team, only: %i[ edit update show add_member send_invite upload_jersey upload_logo generate_logo generate_jersey]
  before_action :authenticate_or_allow_with_token!, only: [ :show ]

  def index
    @user_teams = current_user.teams
    @captain_teams = Team.joins(:team_members)
                     .where(team_members: { user_id: current_user.id, role: TeamMember.roles[:captain] })
  end

  def edit
    token = params[:token]
    if token.present?
      invitation = TeamInvitation.find_valid_by_token(token)

      if invitation.nil?
        redirect_to root_path, alert: "Invalid or expired invitation."
      elsif invitation.accepted?
        redirect_to root_path, alert: "This invitation has already been accepted."
      elsif !user_signed_in?
        # Redirect to sign up with token in params
        session[:team_invitation_token] = token
        redirect_to new_user_registration_path, notice: "Please create an account to accept this invitation."
      else
        # User is logged in and invitation is valid
        @team = invitation.team
        @invitation = invitation
        @invitation_token = token
        flash.now[:notice] = "Welcome! Please complete your profile before joining the team."
      end
    else
      authenticate_user! if !user_signed_in?
    end
  end

  def add_member
    @team_member = @team.team_members.build(team_member_params)
    @team_member.role = :player

    if @team_member.save

      redirect_to @team, notice: "User added to team."
    else
      redirect_to @team, alert: "Error adding user to team."
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to @team, alert: "Error adding user to team."
  end

  def send_invite
    invitation, raw_token = TeamInvitation.create_with_token!(
      team: @team,
      invitee_email: team_invitation_params[:invitee_email],
      inviter: current_user,
      role: :player
    )

    # Send invitation email
    TeamInvitationMailer.invite_email(invitation, raw_token).deliver_later
    redirect_to @team, notice: "Team invitation sent successfully!"
  rescue StandardError => e
    invitation&.destroy if defined?(invitation) && invitation&.persisted?
    redirect_to @team, alert: "Failed to send invitation: #{e.message}."
  end

  def upload_logo
    return unless require_captain!
    if @team.update(logo: params[:logo])
      redirect_to edit_team_path(@team), notice: "Logo uploaded successfully!"
    else
      redirect_to edit_team_path(@team), alert: "Failed to upload logo: #{@team.errors.full_messages.join(', ')}"
    end
  rescue StandardError => e
      redirect_to edit_team_path(@team), alert: "Failed to upload logo: #{e.message}"
  end

  def generate_logo
    return unless require_captain!
    AiLogoGenerator.new(@team, params[:logo_description]).generate!
    redirect_to edit_team_path(@team), notice: "Team Logo generated!"
  rescue StandardError => e
    Rails.logger.error "Logo generation failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to edit_team_path(@team), alert: "Failed to generate logo: #{e.message}"
  end

  def upload_jersey
    return unless require_captain!
    if @team.update(jersey: params[:jersey])
      redirect_to edit_team_path(@team), notice: "Team Jersey uploaded successfully!"
    else
      redirect_to edit_team_path(@team), alert: "Failed to upload jersey: #{@team.errors.full_messages.join(', ')}"
    end
  rescue StandardError => e
    redirect_to edit_team_path(@team), alert: "Failed to upload jersey: #{e.message}"
  end

  def generate_jersey
    return unless require_captain!
    unless @team.logo.attached?
      redirect_to edit_team_path(@team), alert: "Upload or generate a team logo first" and return
    end
    AiJerseyGenerator.new(@team, params[:jersey_description]).generate!
    redirect_to edit_team_path(@team), notice: "Team Jersey generated!"
  rescue StandardError => e
    Rails.logger.error "Jersey generation failed: #{e.message}\n#{e.backtrace.first(10).join("\n")}"
    redirect_to edit_team_path(@team), alert: "Failed to generate jersey: #{e.message}"
  end

  def update
    if @team.update(team_params)
      # Accept token if present in params or session
      token = params[:token] || session.delete(:team_invitation_token)
      if token.present?
        invitation = TeamInvitation.find_valid_by_token(token)
        invitation&.accept!(current_user)
        redirect_to @team, notice: "Team updated and invitation accepted!"
      else
        redirect_to @team, notice: "Team updated successfully."
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show
    @users = User.all - (current_user ? [ current_user ] : [])
    @team_members = @team.team_members.includes(:user)
    @team_member = @team.team_members.build if current_user

    if token_params.present?
      @invitation = TeamInvitation.find_valid_by_token(token_params)
      @invitation_token = token_params if @invitation
    end
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def authenticate_or_allow_with_token!
    # If user is not logged in but has a token, redirect to signup
    if current_user.nil?
      if token_params.present?
        invitation = TeamInvitation.find_valid_by_token(token_params)
        if invitation.nil?
          redirect_to root_path, alert: "Invalid or expired invitation token." and return
        end
        # Redirect to signup with token in session
        session[:team_invitation_token] = token_params
        redirect_to new_user_registration_path, notice: "Please create an account to accept this invitation."
      else
        authenticate_user!
      end
    end
  end

  def require_captain!
    current_team_member = @team.team_members.find_by(user: current_user)
    unless current_team_member&.captain?
      redirect_to edit_team_path(@team), alert: "Only the team captain can access this" and return false
    end
    true
  end

  def team_member_params
    params.require(:team_member).permit(:user_id)
  end

  def team_invitation_params
    params.require(:team_invitation).permit(:invitee_email, :token)
  end

  def token_params
    params[:token]
  end

  def team_params
    params.require(:team).permit(:name, :user_id, :jersey, :logo)
  end
end
