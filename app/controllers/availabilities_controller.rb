class AvailabilitiesController < ApplicationController
  before_action :set_availability, only: [:show, :edit, :update, :destroy]

  # GET /availabilities
  # GET /availabilities.json
  def index
    @availabilities = Availability.all
  end

  # GET /availabilities/1
  # GET /availabilities/1.json
  def show
  end

  # GET /availabilities/new
  def newcontacts
    @availability = Availability.new
  end

  # GET /availabilities/1/edit
  def edit
  end

  # POST /availabilities
  # POST /availabilities.json
  def create

    if (Availability.where("deliveryman_id = ? AND shop_id != ?", params[:deliveryman_id], params[:shop_id]).count > 0)
      respond_to do |format|
        format.html { render :new }
        format.json { render json: {notice: 'Vous ne pouvez pas proposer de livraison dans un autre magasin.'} }
      end
    end

    schedules = params[:schedules]

    schedules.each do |schedule|
      schedule[1].each do |hours|
        date = Date.parse(schedule[0]).beginning_of_day()
        @schedule = Schedule.find_or_create_by(date: date, schedule: hours) do |this|
          this.date = date
          this.schedule = hours
          this.was_created = true
        end
        if @schedule.was_created
          @availability = Availability.create! schedule_id: @schedule.id, shop_id: params[:shop_id], deliveryman_id: params[:deliveryman_id], enabled: true
        end
      end
    end

    respond_to do |format|
      if @schedule.was_created
        format.html { redirect_to @availability, notice: 'Availabilities was successfully created.' }
        format.json { render :show, status: :created, location: @availability }
      else
        format.html { render :new }
        format.json { render json: {notice: 'Les créneaux chosis sont déjà pris par une autre commande'} }
      end
    end
  end

  # PATCH/PUT /availabilities/1
  # PATCH/PUT /availabilities/1.json
  def update
    respond_to do |format|
      if @availability.update(availability_params)
        format.html { redirect_to @availability, notice: 'Availability was successfully updated.' }
        format.json { render :show, status: :ok, location: @availability }
      else
        format.html { render :edit }
        format.json { render json: @availability.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /availabilities/1
  # DELETE /availabilities/1.json
  def destroy
    @availability.destroy
    respond_to do |format|
      format.html { redirect_to availabilities_url, notice: 'Availability was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_availability
      @availability = Availability.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def availability_params
      ap params
      params.require(:availability).permit(:shop_id, :deliveryman_id, :enabled, :schedules)
    end
end
