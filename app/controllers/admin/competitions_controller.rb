class Admin::CompetitionsController < ApplicationController
  before_action :set_competition, only: %i[ show edit update send_invite generate_league ]

  def index
    @competitions = Competition.all
  end

  def show
    @teams = @competition.teams
  end

  def new
    @competition = Competition.new(sport: "unassigned")
  end

  def create
    competition_admin = current_user.competition_admins.first_or_create!
    @competition = competition_admin.competitions.new(competition_params)
    if @competition.save
      redirect_to admin_competition_path(@competition)
    else
      render :new
    end
  end




  def edit
  end

  def update
    if @competition.update(competition_params)
      redirect_to admin_competition_path(@competition)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def send_invite
    @team = Team.new(name: team_invitation_params[:name], competition: @competition)

    if @team.save
      invitation, raw_token = TeamInvitation.create_with_token!(
        team: @team,
        invitee_email: team_invitation_params[:invitee_email],
        inviter: current_user,
        role: team_invitation_params[:role].presence || :captain
        )

      TeamInvitationMailer.invite_email(invitation, raw_token).deliver_later
      redirect_to admin_competition_path(@competition), notice: "Team invitation sent successfully!"
    else
      redirect_to admin_competition_path(@competition), alert: "Failed to create team: #{@team.errors.full_messages.join(', ')}"
    end
  rescue StandardError => e
    @team&.destroy if @team&.persisted?
    redirect_to admin_competition_path(@competition), alert: "Failed to send invitation: #{e.message}"
  end

  def generate_league
    # Params[:round_count]
    # Create number of rounds from admin/competitions/show
    round_count = params[:round_count].to_i
    round_count.times { Round.create!(competition_id: @competition.id) }
    generate_games
  rescue StandardError => e
    redirect_to admin_competition_path(@competition), alert: "Failed to generate league: #{e.message}"
  end

  def generate_games
    @rounds = @competition.rounds
    @teams = @competition.teams
    @game_count = @teams.count / 2
    @game_count += 1 if @game_count.odd?
    # Iterate over rounds and create blank games
    @rounds.each do |round|
      @game_count.times { Game.create!(round_id: round.id) }
    end
  end

  def populate_league
    # Form promt to send open_ai_api:
    # "I am organising a sports competition using a ruby on rails app. I have generated multiple empty rounds and games.
    # Each team needs to play each other #{ties} times and the maximum number a team can play is #{games_a_week} times.
    # The competition starts at #{@competition.start_date} and ends on #{@competition.end_date}.
    # If there is an uneven amount of teams a bye round can be designated by allocating the odd team as team_1_id to the extra game and setting bye to true. For example game.bye: true, game.team_1_id: odd_team "
    # "Here are the teams and the rounds: #{rounds.all}, games: #{games.all}, teams: #{teams.all}"
    # Open ai to respond with JSON as follows:
    round_1 = {
      round_id: round_id,
      games = [{game_id: game_id, team_1_id: team_1_id, team_2_id: team_2_id, bye: false, start_time: start_time, location: location},
                {}] 
    }
    
    
    
    
    { round_id: response[:round_id],
      team_a_id: response[:team_1_id],
      team_b_id: response[:team_2_id],
      starts_at: response[:start_time] }
  end

  private

  def set_competition
    @competition = Competition.find(params[:id])
  end

  def team_invitation_params
    params.require(:team_invite).permit(:name, :invitee_email, :role)
  end

  def competition_params
    params.require(:competition).permit(:name, :sport, :start_date, :end_date)
  end
end
