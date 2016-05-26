class DeliveryRequestsController < BaseController
  before_action :set_delivery_request, only: [:show, :edit, :cancel, :update, :destroy]

  # GET /delivery_requests
  # GET /delivery_requests.json
  def index
    @delivery_requests = DeliveryRequest.all
  end

  # GET /delivery_requests/1
  # GET /delivery_requests/1.json
  def show
  end

  # GET /delivery_requests/new
  def new
    @delivery_request = DeliveryRequest.new
  end

  # GET /delivery_requests/1/edit
  def edit
  end

  # POST /delivery_requests
  # POST /delivery_requests.json
  def create

    if params[:schedule].present?

      params[:schedule].each do |schedule|
        schedule[1].each do |hours|
          @date = Date.parse(schedule[0]).beginning_of_day
          @hours = hours
        end
      end

      if (Schedule.exists?(date: @date, schedule: @hours))
        @schedule = Schedule.find_by(date: @date, schedule: @hours)

        @address = Address.new(address: params[:address_attributes][:address], city: params[:address_attributes][:city], zip: params[:address_attributes][:zip], additional_address: params[:address_attributes][:additional_address])
        if @address.save

          @delivery_request = DeliveryRequest.create! buyer_id: params[:buyer_id], schedule_id: @schedule.id, shop_id: params[:shop_id], address_id: @address.id
          if @delivery_request.save
            Address.update(@address.id, delivery_request_id: @delivery_request.id)
            respond_to do |format|
              format.html { redirect_to @delivery_request, notice: 'Delivery request was successfully created.' }
              format.json { render :show, status: :created, location: @delivery_request }
            end and return

          end

        end

      else

        respond_to do |format|
          format.html { redirect_to @delivery_request, notice: 'Aucun livreur n\'est disponible pour ce créneau de livraison.' }
          format.json { render json: {errors: 'NO_DELIVERYMAN' } }
        end and return

      end

    else

      respond_to do |format|
        format.html { render :new }
        format.json { render json: {notice: 'Veuillez rensigner un créneau valide.'}, status: :unprocessable_entity }
      end and return

    end

  end

  # POST /delivery_requests/1/cancel
  # POST /delivery_requests/1/cancel.json
  def cancel
    respond_to do |format|
      if !@delivery_request.nil? && !@delivery_request.delivery_id.nil?

        @delivery = Delivery.find(@delivery_request.delivery_id)
        if @delivery.status != 'done'


          @delivery = Delivery.find(@delivery_request.delivery_id)
          meta = @delivery.to_meta(false)

          if @delivery.status != 'canceled'
            Notification.where(user_id: @delivery_request.buyer_id).last.update(read: true)
            Notification.create! mode: 'outdated_delivery', title: 'Livraison annulée', content: 'L\'acheteur a annulé la livraison', sender: 'push', user_id: @delivery.availability.deliveryman_id, meta: meta.to_json, read: false
            Notifier.send_canceled_delivery_request(@delivery.availability.deliveryman, @delivery).deliver_now
          end

          Delivery.update(@delivery_request.delivery_id, :status => 'canceled')

        end
        format.html { redirect_to @delivery, notice: 'Delivery was successfully canceled.' }
        format.json { head :no_content }
      elsif !@delivery_request.nil?
        @delivery_request.destroy
        format.html { redirect_to delivery_requests_url, notice: 'Delivery Request was successfully canceled.' }
        format.json { head :no_content }
      else
        format.html { render :new }
        format.json { render json: {}, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /delivery_requests/1
  # PATCH/PUT /delivery_requests/1.json
  def update
    respond_to do |format|
      if @delivery_request.update(delivery_request_params)
        format.html { redirect_to @delivery_request, notice: 'Delivery request was successfully updated.' }
        format.json { render :show, status: :ok, location: @delivery_request }
      else
        format.html { render :edit }
        format.json { render json: @delivery_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /delivery_requests/1
  # DELETE /delivery_requests/1.json
  def destroy
    @delivery_request.destroy
    respond_to do |format|
      format.html { redirect_to delivery_requests_url, notice: 'Delivery request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery_request
      @delivery_request = DeliveryRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def delivery_request_params
      params.require(:delivery_request).permit(:buyer_id, :schedule, :shop_id)
    end
end
