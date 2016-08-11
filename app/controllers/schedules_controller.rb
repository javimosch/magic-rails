class SchedulesController < BaseController
  before_action :set_schedule, only: [:show, :edit, :update, :destroy]

  # Retourne la liste de tous les créneaux.
  #
  # @note GET /schedules
  # @note GET /schedules.json
  def index
    @schedules = Schedule.all
  end


  # Retourne le créneau correspondant au paramètre 1.
  #
  # @note GET /schedules/1
  # @note GET /schedules/1.json
  def show
  end

  # Affiche le formulaire de création d'un nouveau créneau.
  #
  # @note GET /schedules/new
  def new
    @schedule = Schedule.new
  end

  # Affiche le formulaire d'édition d'un créneau correspondant au paramètre 1.
  #
  # @note GET /schedules/1/edit
  def edit
  end

  # Créée un nouveau créneau.
  #
  # @note POST /schedules
  # @note POST /schedules.json
  def create
    @schedule = Schedule.new(schedule_params)

    respond_to do |format|
      if @schedule.save
        format.html { redirect_to @schedule, notice: 'Schedule was successfully created.' }
        format.json { render :show, status: :created, location: @schedule }
      else
        format.html { render :new }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # Mise à jour du créneau correspondant au paramètre 1.
  #
  # @note PATCH/PUT /schedules/1
  # @note PATCH/PUT /schedules/1.json
  def update
    respond_to do |format|
      if @schedule.update(schedule_params)
        format.html { redirect_to @schedule, notice: 'Schedule was successfully updated.' }
        format.json { render :show, status: :ok, location: @schedule }
      else
        format.html { render :edit }
        format.json { render json: @schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # Suppression du créneau correspondant au paramètre 1.
  #
  # @note DELETE /ratings/1
  # @note DELETE /ratings/1.json
  def destroy
    @schedule.destroy
    respond_to do |format|
      format.html { redirect_to schedules_url, notice: 'Schedule was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_schedule
      @schedule = Schedule.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def schedule_params
      params.require(:schedule).permit(:schedule, :date)
    end
end
