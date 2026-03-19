class Admin::CompetitionsController < ApplicationController
  before_action :set_competition, only: %i[ show edit update create_team send_invite generate_league ]

  def index
    @competitions = Competition.all
    @user = User.all
  end

  def show
    @teams = @competition.teams
    @available_captains = User.order(:first_name, :last_name, :email)
    @user = User.find(params[:id])
    @user_email = current_user.email
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
    raise ArgumentError, "League scaffold has already been generated" if @competition.scaffold_generated?
    ties = params[:ties].to_i
    @teams = @competition.teams
    team_count = @competition.teams.count

    raise ArgumentError, "At least two teams are required to generate a league" if team_count < 2
    raise ArgumentError, "Ties must be greater than 0" if ties <= 0

    ActiveRecord::Base.transaction do
      round_count_for(team_count, ties).times do
        @competition.rounds.create!
      end

      generate_games(team_count)
      populate_league
    end

    @competition.update!(scaffold_generated: true)
    redirect_to admin_competition_path(@competition), notice: "League scaffold created successfully."
  rescue StandardError => e
    Rails.logger.error("Generate league failed: #{e.class}")
    Rails.logger.error("Message: #{e.message}")
    Rails.logger.error("Backtrace: #{e.backtrace.first(10).join("\n")}")
    redirect_to admin_competition_path(@competition), alert: "Failed to generate league: #{e.message}"
  end

  def generate_games(team_count)
    game_count = games_per_round(team_count)

    @competition.rounds.find_each do |round|
      game_count.times { round.games.create! }
    end
  end

  def populate_league
    @rounds = @competition.rounds
    matchup_limit = params[:ties].to_i
    matchups = {}

    Rails.logger.info("Starting populate_league: #{@rounds.count} rounds, matchup_limit: #{matchup_limit}")

    @rounds.each_with_index do |round, round_idx|
      Rails.logger.info("Processing round #{round_idx} with #{round.games.count} games")

      teams = @teams.shuffle
      @round_teams = []

      round.games.each_with_index do |game, game_idx|
        Rails.logger.info("  Game #{game_idx}: team_1=#{game.team_1_id}, team_2=#{game.team_2_id}")

        teams.each do |team|
          break if game.has_teams?

          if @round_teams.include?(team)
            Rails.logger.debug("    Team #{team.id} already used in round")
            next
          else
            # Only assign opponent if one team slot is filled
            unless game.team_1_present? || game.team_2_present?
              Rails.logger.info("    No opponent yet, assigning team #{team.id} to team_1")
              game.update!(team_1_id: team.id)
              @round_teams << team
              next
            end

            opponent = game.team_1_present? ? game.team_1 : game.team_2
            key = [ team.id, opponent&.id ].sort.join("-")

            if opponent && matchups[key].to_i >= matchup_limit
              Rails.logger.debug("    Matchup limit reached for key #{key}")
              next
            end

            game.update!(team_2_id: team.id)
            @round_teams << team

            if game.has_teams?
              matchups[key] = matchups[key].to_i + 1
              Rails.logger.info("    Game complete: #{game.team_1_id} vs #{game.team_2_id}, count: #{matchups[key]}")
              break
            end
          end
        end
      end

      # Clean up empty games and mark byes
      round.games.each_with_index do |game, game_idx|
        if game.empty?
          Rails.logger.info("    Destroying empty game #{game_idx}")
          game.destroy
        elsif game.bye?
          Rails.logger.info("    Marking game #{game_idx} as bye (only one team)")
          game.update!(bye: true)
        end
      end

      Rails.logger.info("Round #{round_idx} complete. Matchups: #{matchups}")
    end
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
