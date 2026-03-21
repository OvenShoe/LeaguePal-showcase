class Admin::RoundsController < Admin::BaseController
  before_action :set_round, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /rounds or /rounds.json
  def index
    @rounds = Round.all
  end

  # GET /rounds/1 or /rounds/1.json
  def show
    @games = @round.games
    @teams = @round.competition.teams
    @games_count = @games.count
    @teams_count =  @teams.count
  end

  # GET /rounds/new
  def new
    @round = Round.new
  end

  # GET /rounds/1/edit
  def edit
  end

  # POST /rounds or /rounds.json
  def create
    @round = Round.new(round_params)

    respond_to do |format|
      if @round.save
        # Redirect to competiton#show where the form to add a round will be
        format.html { redirect_to admin_competition_path(@round.competition), notice: "Round was successfully created." }
        format.json { render :show, status: :created, location: @round }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @round.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rounds/1 or /rounds/1.json
  def update
    respond_to do |format|
      if @round.update(round_params)
        format.html { redirect_to admin_round_path(@round), notice: "Round was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @round }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @round.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rounds/1 or /rounds/1.json
  def destroy
    @competition = @round.competition
    @round.destroy!

    respond_to do |format|
      format.html { redirect_to admin_competition_path(@competition), notice: "Round was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_round
      @round = Round.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def round_params
      params.require(:round).permit(:name, :id)
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
