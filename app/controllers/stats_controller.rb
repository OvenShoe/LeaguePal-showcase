class StatsController < ApplicationController
  before_action :set_stat, only: %i[ show edit update destroy ]
  before_action :set_game, only: %i[ create edit update ]
  before_action :authenticate_user!
  before_action :validate_user, only: %i[ create edit update destroy ]


  # GET /stats or /stats.json
  def index
    @stats = Stat.all
  end

  def show
  end

  # GET /stats/1/edit
  def edit
  end

  # POST /stats or /stats.json
  def create
    Rails.logger.info(
      "[Stats#create] start user_id=#{current_user&.id} game_id=#{params[:game_id]} " \
      "format=#{request.format} turbo_frame=#{request.headers['Turbo-Frame'] || 'none'}"
    )

    @stat = @game.stats.build(stat_params.except(:game_id))
      Rails.logger.debug(
        "[Stats#create] built stat game_id=#{@stat.game_id} user_id=#{@stat.user_id} " \
        "label=#{@stat.label.inspect} value=#{@stat.value.inspect}"
      )

    respond_to do |format|
      if @stat.save
        Rails.logger.info(
          "[Stats#create] success stat_id=#{@stat.id} game_id=#{@game.id} user_id=#{@stat.user_id}"
        )
        format.html { redirect_to game_path(@game), notice: "stat was successfully created." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "statscard",
            partial: "shared/statscard",
            locals: { top_stats: @game.top_stat_per_label,
            title: "Top Stats This Game", show_user: true }
          )
        end
      else
        Rails.logger.warn(
          "[Stats#create] failed game_id=#{@game.id} errors=#{@stat.errors.full_messages.join(' | ')}"
        )
        format.html { redirect_to game_path(@game), alert: @stat.errors.full_messages.to_sentence }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "stat_form",
            partial: "stats/form",
            locals: { game: @game, stat: @stat }
          ), status: :unprocessable_entity
        end
      end
    end
  rescue => e
    Rails.logger.error(
      "[Stats#create] exception class=#{e.class} message=#{e.message}\n#{e.backtrace&.first(8)&.join("\n")}"
    )
    raise
  end

  # PATCH/PUT /stats/1 or /stats/1.json
  def update
    respond_to do |format|
      if @stat.update(stat_params)
        format.html { redirect_to game_path(@game), notice: "stat was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @stat }
      else
        format.html { redirect_to game_path(@game), status: :unprocessable_entity }
        format.json { render json: @stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stats/1 or /stats/1.json
  def destroy
    @stat.destroy!

    respond_to do |format|
      format.html { redirect_to game_path(@stat.game), notice: "stat was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:game_id])
      Rails.logger.debug("[Stats#set_game] loaded game_id=#{@game.id}")
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn("[Stats#set_game] game not found game_id=#{params[:game_id]}")
      raise
    end

    def set_stat
      @stat = Stat.find(params.expect(:id))
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

    # Only allow a list of trusted parameters through.
    def stat_params
      params.require(:stat).permit(:user_id, :game_id, :label, :value)
    end
end
