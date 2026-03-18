class GamesController < ApplicationController
  before_action :set_game, only: %i[ show edit update destroy ]

  # GET /games or /games.json
  def index
    @games = Game.all
  end

  # GET /games/1 or /games/1.json
  def show
    @stat_labels = labels(@game)
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
  end

  def game_stats
    # link on game#show to game#stats
    # Show all stats for the game that adapts to @game.sport
    # Table for Teams
    # @team_1_stats =
    # Table for players
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

    def labels(game)
      sport = game.round.competition.sport
      case sport
      when "Netball"
        %i[goals assists intercepts deflections turnovers center_passes rebounds]
      when "Football"
        %i[goals assists shots tackles dribbles duels_won saves yellow_cards red_cards possession]
      # when "Rugby"
      #   %i[tries conversions penalties tackles lineouts scrums yellow_cards red_cards]
      # when "Basketball"
      #   %i[3pointers field_goals slam_dunks free_throws points rebounds assists steals blocks turnovers fouls]
      # when "AFL"
      #   %i[goals behinds kicks handballs marks tackles hitouts disposals]
      # when "Cricket"
      #   %i[runs wickets catches run_outs stumpings maidens wides no_balls]
      # when "Tennis"
      #   %i[aces double_faults first_serve_percentage winners unforced_errors break_points_won games_won sets_won]
      else
        %i[]
      end
    end

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
