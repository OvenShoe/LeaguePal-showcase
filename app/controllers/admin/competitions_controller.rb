class Admin::CompetitionsController < ApplicationController
  before_action :set_competition, only: %i[ show edit update create_team send_invite generate_league ]

  def index
    @competitions = Competition.all
  end

  def show
    @teams = @competition.teams
    @available_captains = User.order(:first_name, :last_name, :email)
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

  def create_team
    user = User.find(team_params[:captain_id])
    team = @competition.teams.build(name: team_params[:name])

    ActiveRecord::Base.transaction do
      team.save!
      team.team_members.create!(user: user, role: :captain)
    end

    redirect_to admin_competition_path(@competition), notice: "Team created successfully."
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_competition_path(@competition), alert: "Captain could not be found."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to admin_competition_path(@competition), alert: "Failed to create team: #{e.record.errors.full_messages.to_sentence}"
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
    # Lock someone out of double scaffolding the competition
    raise ArgumentError, "League scaffold has already been generated" if @competition.scaffold_generated?
    ties = params[:ties].to_i
    team_count = @competition.teams.count

    raise ArgumentError, "At least two teams are required to generate a league" if team_count < 2
    raise ArgumentError, "Ties must be greater than 0" if ties <= 0

    ActiveRecord::Base.transaction do
      round_count_for(team_count, ties).times do
        @competition.rounds.create!
      end

      generate_games(team_count)
    end

    @competition.update!(scaffold_generated: true)
    redirect_to admin_competition_path(@competition), notice: "League scaffold created successfully."
  rescue StandardError => e
    redirect_to admin_competition_path(@competition), alert: "Failed to generate league: #{e.message}"
  end

  def generate_games(team_count)
    game_count = games_per_round(team_count)

    @competition.rounds.find_each do |round|
      game_count.times { round.games.create! }
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
    # round_1 = {
    #   round_id: round_id,
    #   games = [{game_id: game_id, team_1_id: team_1_id, team_2_id: team_2_id, bye: false, start_time: start_time, location: location},
    #             {game_id: game_id, team_1_id: team_1_id, team_2_id: team_2_id, bye: false, start_time: start_time, location: location}, etc...]
    # }
    # Parse the response and update the games with the team ids, start times, and bye status.
    # Save the updated games to the database.
    # Handle any errors that may occur during the process and provide feedback to the admin.
    # Note: The actual implementation of the OpenAI API call and response parsing is not included in this method and should be handled separately.
    # Example of parsing the response:
    # response = JSON.parse(open_ai_response)
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

  def team_params
    params.require(:team).permit(:name, :captain_id)
  end

  def round_count_for(team_count, ties)
    base_rounds = team_count.even? ? team_count - 1 : team_count
    base_rounds * ties
  end

  def games_per_round(team_count)
    team_count.odd? ? (team_count / 2) + 1 : team_count / 2
  end
end
