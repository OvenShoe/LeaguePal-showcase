class GamesController < ApplicationController
  before_action :set_game, only: %i[ show edit update destroy complete_game ]

  # GET /games or /games.json
  def index
    @games = Game.all
  end

  # GET /games/1 or /games/1.json
  def show
    @stat_labels = @game.labels
    # Handles when either team is unassigned as well as a bye
    @stat = Stat.new
    @team_1 = @game.team_1_present? ? Team.find_by(id: @game.team_1_id) || "No assigned team" : "No assigned team"
    @team_2 = if @game.bye?
      "BYE"
    elsif @game.team_2_present?
      Team.find_by(id: @game.team_2_id) || "No assigned team"
    else
      "No assigned team"
    end
    if @game.start_time.present?
      @start_time = @game.start_time.strftime("%-l:%M %p")
      @date = @game.start_time.strftime("%A %-d#{@game.start_time.day.ordinal} %B, %Y")
    else
      @date = "TBA"
      @start_time = "TBA"
    end
    # define a player list to select from when makinga score.
    @players = create_player_list_names(@game)
    @stats = @game.stats

    @team_1_score = if @team_1.is_a?(Team)
      team_1_user_ids = @team_1.team_members.pluck(:user_id)
      @game.stats.where(label: "goals", user_id: team_1_user_ids).sum(:value)
    else
      0
    end

     @team_2_score = if @team_2.is_a?(Team)
      team_2_user_ids = @team_2.team_members.pluck(:user_id)
      @game.stats.where(label: "goals", user_id: team_2_user_ids).sum(:value)
     else
      0
     end
     @top_stats = @game.top_stat_per_label
  end

  def complete_game
    unless current_user.is_admin?
      redirect_to game_path(@game), alert: "You are not authorized to complete games.", status: :see_other
      return
    end

    if @game.complete?
      redirect_to game_path(@game), notice: "Game is already complete.", status: :see_other
      return
    end

    if @game.update(complete: true)
      redirect_to game_path(@game), notice: "Game marked as complete.", status: :see_other
    else
      redirect_to game_path(@game), alert: @game.errors.full_messages.to_sentence, status: :see_other
    end
    if @game.complete?
      @winner = winner(@game)
      update_team_stats(@game)
    end
  end

  def winner(game)
    team_ids = [ game.team_1_id, game.team_2_id ].compact
    return nil if team_ids.empty?


    scores_by_team_id = Stat.joins("INNER JOIN team_members ON team_members.user_id = stats.user_id")
                            .where(game_id: game.id, label: "goals", team_members: { team_id: team_ids })
                            .group("team_members.team_id")
                            .sum(:value)

    team_scores = team_ids.index_with { |team_id| scores_by_team_id[team_id] || 0 }
    highest_score = team_scores.values.max
    winning_team_ids = team_scores.select { |_team_id, score| score == highest_score }.keys

    if winning_team_ids.size > 1
      # Draw: update draws for both teams
      teams = Team.where(id: winning_team_ids)
      teams.each do |team|
        draws = team.draws.to_i + 1
        team.update!(draws: draws)
      end
      return :draw
    end

    # Win/Loss: update winner and loser
    winner = Team.find_by(id: winning_team_ids.first)
    wins = winner.wins.to_i + 1
    winner.update!(wins: wins)

    # Find the losing team (the other team in the game)
    loser_id = ([ game.team_1_id, game.team_2_id ] - [ winner.id ]).first
    if loser_id
      loser = Team.find_by(id: loser_id)
      if loser
        losses = loser.losses.to_i + 1
        loser.update!(losses: losses)
      end
    end
  end

  def update_team_stats(game)
    teams = game.teams
    stats = game.stats

    # Calculate goals for each team
    team_goals = {}
    teams.each do |team|
      user_ids = team.team_members.pluck(:user_id)
      team_goals[team.id] = stats.where(label: "goals", user_id: user_ids).sum(:value)
    end

    # Determine outcome for form
    team_ids = teams.map(&:id)
    highest_score = team_goals.values.max
    winning_team_ids = team_goals.select { |_team_id, score| score == highest_score }.keys
    draw = winning_team_ids.size > 1

    teams.each do |team|
      # Determine outcome for this team
      if draw
        outcome = "D"
      elsif team.id == winning_team_ids.first
        outcome = "W"
      else
        outcome = "L"
      end

      # Update form (prepend most recent outcome, keep last 5)
      form = team.form.to_s
      new_form = (outcome + form)[0, 5]

      # Update games played
      games_played = team.games_played.to_i + 1

      # Points for: goals scored by this team
      points_for = team.points_for.to_i + team_goals[team.id].to_i

      # Points against: goals scored by opponent
      opponent_id = (team_ids - [ team.id ]).first
      points_against = team.points_against.to_i + team_goals[opponent_id].to_i

      team.update!(
        form: new_form,
        games_played: games_played,
        points_for: points_for,
        points_against: points_against
      )
    end
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games or /games.json
  def create
    @game = Game.new(game_params)
    @round = @game.round

    unless @round
      respond_to do |format|
        format.html { redirect_to admin_competitions_path, alert: "Round is required to create a game.", status: :see_other }
        format.json { render json: { error: "round_id is required" }, status: :unprocessable_entity }
      end
      return
    end

    respond_to do |format|
      if @game.save
        format.html { redirect_to admin_round_path(@round), notice: "Game was successfully created." }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { redirect_to admin_round_path(@round), alert: @game.errors.full_messages.to_sentence, status: :see_other }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1 or /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        # Redirect to round#show
        format.html { redirect_to admin_round_path(@game.round), notice: "Game was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1 or /games/1.json
  def destroy
    @round = @game.round
    @game.destroy!

    respond_to do |format|
      format.html { redirect_to admin_round_path(@round), notice: "Game was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

    def create_player_list_names(game)
      # find both teams
      list_names = []
      if game.team_1_present?
        team_1 = Team.find(game.team_1_id)
        team_1.team_members.each { |player| list_names << [ player.list_name, player.user.id ] }
      end
      if game.team_2_present?
        team_2 = Team.find(game.team_2_id)
        team_2.team_members.each { |player| list_names << [ player.list_name, player.user.id ] }
      end
      # Return array of list names
      list_names.uniq
    end

    def set_game
      @game = Game.find(params.expect(:id))
    end

  # Only allow a list of trusted parameters through.
  def game_params
    params.require(:game).permit(:team_1_id, :team_2_id, :location, :start_time, :round_id)
  end
end
