class DeliveryRequestsController < BaseController
  before_action :set_delivery_request, only: [:show, :edit, :cancel, :update, :destroy]

  # Retourne la liste de toutes les demandes de livraison.
  #
  # @note GET /delivery_requests
  # @note GET /delivery_requests.json
  def index
    @delivery_requests = DeliveryRequest.all
  end

  # Retourne la demande de livraison correspondant au paramètre 1.
  #
  # @note GET /delivery_requests/1
  # @note GET /delivery_requests/1.json
  def show
  end

  # Affiche le formulaire de création d'une nouvelle demande de livraison.
  #
  # @note GET /delivery_requests/new
  def new
    @delivery_request = DeliveryRequest.new
  end

  # Affiche le formulaire d'édition d'une demande de livraison correspondant au paramètre 1.
  #
  # @note GET /delivery_request/1/edit
  def edit
  end

  # Créée une nouvelle demande de livraison.
  #
  # @note POST /delivery_request
  # @note POST /delivery_request.json
  def create

    if params[:schedule].present?

      params[:schedule].each do |schedule|
        schedule[1].each do |hours|
          @date = Date.parse(schedule[0]).beginning_of_day
          @hours = hours
        end
      end

      @schedule = Schedule.find_or_create_by(date: @date, schedule: @hours)

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
        format.html { render :new }
        format.json { render json: {notice: 'Veuillez rensigner un créneau valide.'}, status: :unprocessable_entity }
      end and return
    end

  end
  
  # Save products from a cart and associate them with DeliveryRequest when there is not a Delivery registry.
  #
  # @note POST /delivery_requests/saveProducts/1.json
  def saveProducts
    
    delivery_request_id = params.require(:delivery_request).permit(:id)[:id]
    delivery_contents = params.require(:delivery_request).require(:delivery_contents)

    if delivery_contents.nil? then
      return render json:{notice: 'EMPTY_CART'}, status:500
    end
    
    logger.debug "delivery_request_id #{delivery_request_id}"
    logger.debug "delivery_contents #{delivery_contents}"
    
    DeliveryContent.destroy_all(delivery_request: delivery_request_id)
    delivery_contents.each do |delivery_content|
      DeliveryContent.create! id_delivery: nil, delivery_request_id: delivery_request_id, id_product: delivery_content[:id_product], quantity: delivery_content[:quantity], unit_price: delivery_content[:unit_price]
    end
    
    respond_to do |format|
      format.json { render json:{notice: 'Saved'}, status:200 }
    end
  end
  
  # Fetch products from DeliveryRequest
  #
  # @note POST /delivery_request/fetchProducts/1.json
  def fetchProducts
    
    @delivery_request = DeliveryRequest.find(params[:id])
    @delivery_contents = nil
    
    # grab producs from request or delivery
    delivery = Delivery.where({delivery_request_id: params[:id]})
    if !delivery.nil? and delivery.count>0 then
      delivery = delivery.first()
      @delivery_contents = DeliveryContent.where(id_delivery: delivery.id)
    else
      @delivery_contents = DeliveryContent.where(delivery_request_id: params[:id])
    end
      
    #delivery_contents_from_delivery = DeliveryContent.where({id_delivery: delivery.id})
    #.where('id NOT IN (?)', @delivery_contents.pluck(:id))
    #if !delivery_contents_from_delivery.nil? then
    #  @delivery_contents.concat delivery_contents_from_delivery
    #end
    
    
    logger.debug "RESULT RESULT  #{@delivery_contents.inspect}"
    
    #respond_to do |format|
    #  format.json { render json:{notice: 'some',delivery_contents: @delivery_contents}, status:200 }
    #end
  end

  # Annulation de la demande de livraison correspondant au paramètre 1.
  #
  # @note POST /delivery_requests/1/cancel
  # @note POST /delivery_requests/1/cancel.json
  def cancel
    respond_to do |format|
      if !@delivery_request.nil? && !@delivery_request.delivery_id.nil?

        @delivery = Delivery.find(@delivery_request.delivery_id)
        if @delivery.status != 'done'


          @delivery = Delivery.find(@delivery_request.delivery_id)
          meta = @delivery.to_meta(false)

          if @delivery.status != 'canceled'
            Notification.where(user_id: @delivery_request.buyer_id).last.update(read: true)
            Notification.create! mode: 'canceled_delivery', title: 'Livraison annulée', content: 'L\'acheteur a annulé la livraison', sender: 'push', user_id: @delivery.availability.deliveryman_id, meta: meta.to_json, read: false
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

  # Mise à jour de la demande de livraison correspondant au paramètre 1.
  #
  # @note PATCH/PUT /delivery_requests/1
  # @note PATCH/PUT /delivery_requests/1.json
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

  # Suppression de la demande de livraison correspondant au paramètre 1.
  #
  # @note DELETE /delivery_requests/1
  # @note DELETE /delivery_requests/1.json
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
      params.require(:delivery_request).permit(:buyer_id, :schedule, :shop_id,:delivery_contents)
    end
end
