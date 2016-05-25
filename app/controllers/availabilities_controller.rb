class AvailabilitiesController < BaseController
  before_action :set_availability, only: [:show, :edit, :update, :destroy, :cancel]

  # GET /availabilities
  # GET /availabilities.json
  def index
    @availabilities = Availability.joins(:schedule).where(deliveryman_id: current_user.id, enabled: true).where('schedules.date >= ?', Time.now.beginning_of_day)

    ids = []
    @availabilities.each do |order|
      ids.push(order.id)
    end

    @deliveries = Delivery.where(availability_id: ids)
    @deliveries.each do |delivery|
      @availability = @availabilities.detect{|w| w.delivery_id == delivery.id}
      if @availability
        @availability.delivery = delivery
      end
    end
  end

  # GET /availabilities/1
  # GET /availabilities/1.json
  def show
  end

  # GET /availabilities/new
  def new
    @availability = Availability.new
  end

  # GET /availabilities/1/edit
  def edit
  end

  # POST /availabilities
  # POST /availabilities.json
  def create

    if (Availability.where("deliveryman_id = ? AND shop_id != ? AND enabled = ?", params[:deliveryman_id], params[:shop_id], true).count > 0)
      respond_to do |format|
        format.html { render :new }
        format.json { render json: {notice: 'Vous ne pouvez pas proposer de livraison dans un autre magasin.'} }
      end and return
    end

    schedules = params[:schedules]

    schedules.each do |schedule|
      hours = schedules[schedule[0]]
      hours.each do |hour|
        date = Date.parse(schedule[0]).beginning_of_day()
        @schedule = Schedule.find_or_create_by(date: date, schedule: hour) do |this|
          this.date = date
          this.schedule = hour
          this.was_created = true
        end
        @availability = Availability.create! schedule_id: @schedule.id, shop_id: params[:shop_id], deliveryman_id: params[:deliveryman_id], enabled: true
      end
    end

    respond_to do |format|
      format.html { redirect_to @availability, notice: 'Availabilities was successfully created.' }
      format.json { render :show, status: :created, location: @availability }
    end
  end

  # POST /availabilities/1/cancel
  # POST /availabilities/1/cancel.json
  def cancel
    respond_to do |format|
      if !@availability.nil? && !@availability.delivery_id.nil?
        @delivery = Delivery.find(@availability.delivery_id)

        if @delivery.status === 'completed'
            format.html { render :new }
            format.json { render json: { notice: 'COMPLETED_DELIVERY' }, status: :unprocessable_entity }
        else
          Availability.update(@availability.id, :enabled => false)

          if @delivery.status != 'done'
            Delivery.update(@availability.delivery_id, :status => 'canceled')

            @delivery = Delivery.find(@availability.delivery_id)
            meta = @delivery.to_meta(false)

            Notification.create! mode: 'outdated_delivery', title: 'Livraison annulée', content: 'Votre livreur a annulé la livraison', sender: 'push', user_id: @delivery.delivery_request.buyer_id, meta: meta.to_json, read: false
            Notifier.send_canceled_delivery_availability(@delivery.delivery_request.buyer, @delivery).deliver_now
          end

          format.html { redirect_to @delivery, notice: 'Delivery was successfully canceled.' }
          format.json { head :no_content }
        end
      elsif !@availability.nil?
        @availability.destroy
        format.html { redirect_to availabilities_url, notice: 'Availability was successfully canceled.' }
        format.json { head :no_content }
      else
        format.html { render :new }
        format.json { render json: {}, status: :unprocessable_entity }
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
