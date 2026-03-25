class Admin::CompetitionsController < ApplicationController
  before_action :set_competition, only: %i[ show edit update create_team send_invite generate_league add_game_dates ]
  before_action :authenticate_user!

  def index
    @competitions = Competition.all
    @user = User.all
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
      flash.now[:alert] = "Please fix the errors below."
      render :new, status: :unprocessable_entity
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
      begin
        raise ArgumentError, "League scaffold has already been generated" if @competition.scaffold_generated?

        permitted = generate_league_params
        ties = permitted[:ties].to_i
        comp = permitted[:competition] || ActionController::Parameters.new

        game_days = if comp.key?(:game_days) || comp.key?("game_days")
                      Array(comp[:game_days] || comp["game_days"]).reject(&:blank?).map(&:to_i)
        else
                      Array(@competition.game_days)
        end

        start_times = if comp.key?(:start_times) || comp.key?("start_times")
                        Array(comp[:start_times] || comp["start_times"]).reject(&:blank?)
        else
                        Array(@competition.start_times)
        end

        locations = if comp.key?(:locations) || comp.key?("locations")
                      Array(comp[:locations] || comp["locations"]).reject(&:blank?)
        else
                      Array(@competition.locations)
        end

        raise ArgumentError, "Please select at least one game day" if game_days.empty?
        raise ArgumentError, "Please select at least one start time" if start_times.empty?

        @competition.update!(
          game_days: game_days,
          start_times: start_times,
          locations: locations
        )

        @teams = @competition.teams
        team_count = @teams.count
        locations = Array(@competition.locations).reject(&:blank?)

        raise ArgumentError, "At least two teams are required to generate a league" if team_count < 2
        raise ArgumentError, "Ties must be greater than 0" if ties <= 0

        ActiveRecord::Base.transaction do
          round_count_for(team_count, ties).times { @competition.rounds.create! }
          generate_games(team_count)
          populate_league
          add_game_dates
        end

        @competition.update!(scaffold_generated: true)
        flash[:notice] = "League scaffold created successfully."
        redirect_to admin_competition_path(@competition)
      rescue StandardError => e
        Rails.logger.error("Generate league failed: #{e.class}")
        Rails.logger.error("Message: #{e.message}")
        Rails.logger.error("Backtrace: #{e.backtrace.first(10).join("\n")}")
        flash[:alert] = "Failed to generate league: #{e.message}"
        redirect_to admin_competition_path(@competition)
      end
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
    team_count = @teams.count
    bye_rotation = @teams.to_a.cycle

    Rails.logger.info("Starting populate_league: #{@rounds.count} rounds, matchup_limit: #{matchup_limit}")

    @rounds.each_with_index do |round, round_idx|
      Rails.logger.info("Processing round #{round_idx} with #{round.games.count} games")

      bye_team = team_count.odd? ? bye_rotation.next : nil
      available_teams = @teams.reject { |team| team == bye_team }.shuffle
      round_teams = []

      round.games.each_with_index do |game, game_idx|
        Rails.logger.info("  Game #{game_idx}: team_1=#{game.team_1_id}, team_2=#{game.team_2_id}")

        # Assign roatating bye teams if the @teams.count.odd?
        if bye_team && !round_teams.include?(bye_team) && game.empty?
          game.update!(team_1_id: bye_team.id, bye: :true)
          round_teams << bye_team
          Rails.logger.info("    Assigned bye to team #{bye_team.id}")
          next
        end

        available_teams.each do |team|
          break if game.has_teams?
          if round_teams.include?(team)
            Rails.logger.debug("    Team #{team.id} already used in round")
            next
          else
            # Only assign opponent if one team slot is filled
            unless game.team_1_present? || game.team_2_present?
              Rails.logger.info("    No opponent yet, assigning team #{team.id} to team_1")
              game.update!(team_1_id: team.id)
              round_teams << team
              next
            end

            opponent = game.team_1_present? ? game.team_1 : game.team_2
            key = [ team.id, opponent&.id ].sort.join("-")

            if opponent && matchups[key].to_i >= matchup_limit
              Rails.logger.debug("    Matchup limit reached for key #{key}")
              next
            end

            game.update!(team_2_id: team.id)
            round_teams << team

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
          game.update!(bye: :true)
        end
      end

      Rails.logger.info("Round #{round_idx} complete. Matchups: #{matchups}")
    end
  end

  def add_game_dates
    day_indexes = Array(@competition.game_days).map(&:to_i).uniq.sort
    start_times = Array(@competition.start_times).map(&:to_s).map(&:strip).reject(&:blank?).uniq
    locations  = Array(@competition.locations).map(&:to_s).map(&:strip).reject(&:blank?).uniq

    raise ArgumentError, "Please select at least one game day" if day_indexes.empty?
    raise ArgumentError, "Please select at least one start time" if start_times.empty?
    raise ArgumentError, "Please add at least one location" if locations.empty?
    raise ArgumentError, "Competition start/end dates are required" if @competition.start_date.blank? || @competition.end_date.blank?

    slots = build_game_slots(
      start_date: @competition.start_date.to_date,
      end_date: @competition.end_date.to_date,
      day_indexes: day_indexes,
      start_times: start_times,
      locations: locations
    )

    games = @competition.games.order(:round_id, :id).reject(&:bye?)
    raise ArgumentError, "Not enough date/time/location slots to generate the league" if slots.size < games.size

    games.zip(slots).each do |game, slot|
      game.update!(start_time: slot[:start_time], location: slot[:location])
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
    params.require(:competition).permit(:name, :sport, :start_date, :end_date,
                                        game_days: [], start_times: [], locations: [])
  end

private

  def generate_league_params
    params.permit(:ties, competition: [ game_days: [], start_times: [], locations: [] ])
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

  def schedule_params
    params.permit(game_days: [], start_times: [])
  end

  def build_game_slots(start_date:, end_date:, day_indexes:, start_times:, locations:)
    slots = []

    (start_date..end_date).each do |date|
      next unless day_indexes.include?(date.wday)

      start_times.each do |time_str|
        dt = parse_slot_datetime(date, time_str)

        # same date/time can be reused per different location
        locations.each do |location|
          slots << { start_time: dt, location: location }
        end
      end
    end

    slots.sort_by { |s| [ s[:start_time], s[:location] ] }
  end

  def parse_slot_datetime(date, time_str)
    # Accepts "17:40" or "5:40 PM"
    if time_str.match?(/\A\d{1,2}:\d{2}\z/)
      Time.zone.strptime("#{date} #{time_str}", "%Y-%m-%d %H:%M")
    else
      Time.zone.strptime("#{date} #{time_str}", "%Y-%m-%d %I:%M %p")
    end
  rescue ArgumentError
    raise ArgumentError, "Invalid start time format: #{time_str}"
  end

  def validate_user
    # Only allow user admins to perform CRUD actions
    if current_user.is_admin?
      Rails.logger.debug("[Stats#validate_user] allowed user_id=#{current_user.id}")
    else
      Rails.logger.warn("[Stats#validate_user] blocked user_id=#{current_user&.id}")
      redirect_to games_path, notice: "Current user is not admin"
    end
  end
end
