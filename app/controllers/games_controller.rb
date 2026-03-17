class GamesController < ApplicationController
  before_action :set_game, only: %i[ show edit update destroy ]

  # GET /games or /games.json
  def index
    @games = Game.all
  end

  # GET /games/1 or /games/1.json
  def show
    # Handles when either team is unassigned as well as a bye
    @stat = Stat.new
    @game.team_1_present? ? @team_1 = Team.find(@game.team_1_id) : @team_1 = "No assigned team"
    @team_2 = Team.find(@game.team_2_id) if @game.team_2_present?
    @game.bye? ? @team_2 = "BYE" : @team_2 = "No assigned team"
    if @game.start_time.present?
      @start_time = @game.start_time.strftime("%-l:%M %p")
      @date = @game.start_time.strftime("%A %-d#{@game.start_time.day.ordinal} %B, %Y")
    else
      @date = "TBA"
      @start_time = "TBA"
    end
    # define a player list to select from when makinga score.
    @players = create_player_list_names(@game)
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
