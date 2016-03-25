class DeliveriesController < BaseController
  before_action :set_delivery, only: [:show, :edit, :update, :destroy]

  # GET /deliveries
  # GET /deliveries.json
  def index
    
    @availabilities = Availability.where(deliveryman_id: current_user.id)
    ids = []
    @availabilities.each do |order|
      ids.push(order.id)
    end
    @deliveries = Delivery.where(availability_id: ids)
  
  end

  # GET /orders
  # GET /orders.json
  def orders

    @orders = DeliveryRequest.where(buyer_id: current_user.id, match: false)
    @deliveries = DeliveryRequest.where(buyer_id: current_user.id, match: true)
    ids = []
    @deliveries.each do |delivery|
      ids.push(delivery.id)
    end
    @deliveries = Delivery.where(delivery_request_id: ids)
    
  end

  # GET /deliveries/1
  # GET /deliveries/1.json
  def show
  end

  # GET /deliveries/new
  def new
    @delivery = Delivery.new
  end

  # GET /deliveries/1/edit
  def edit
  end

  # POST /deliveries
  # POST /deliveries.json
  def create

    @delivery = Delivery.new(delivery_params)

    respond_to do |format|
      if @delivery.save
        Delivery.update(@delivery.id, status: 'accepted')
        format.html { redirect_to @delivery, notice: 'Delivery was successfully created.' }
        format.json { render :show, status: :created, location: @delivery }
      else
        format.html { render :new }
        format.json { render json: @delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /finalize
  # POST /finalize.json
  def finalize
    respond_to do |format|
      if Delivery.exists?(id: params[:id], validation_code: params[:validation_code]) 
        Delivery.update(params[:id], status: 'finished')
        format.html { redirect_to @delivery, notice: 'Delivery was successfully set to finished.' }
        format.json { render :show, status: :ok, location: @delivery }
      else
        format.html { render :new }
        format.json { render json: { notice: 'VALIDATION_CODE_ERROR' }, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /deliveries/1
  # PATCH/PUT /deliveries/1.json
  def update

    delivery_contents = params[:delivery_contents]
    delivery_contents.each do |delivery_content|
      DeliveryContent.create! id_delivery: @delivery.id, id_product: delivery_content.id_product, quantity: delivery_content.quantity, unit_price: delivery_content.unit_price
    end

    Delivery.update(@delivery.id, status: 'completed')

    respond_to do |format|
      if @delivery.update(delivery_params)
        format.html { redirect_to @delivery, notice: 'Delivery was successfully updated.' }
        format.json { render :show, status: :ok, location: @delivery }
      else
        format.html { render :edit }
        format.json { render json: @delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deliveries/1
  # DELETE /deliveries/1.json
  def destroy
    @delivery.destroy
    respond_to do |format|
      format.html { redirect_to deliveries_url, notice: 'Delivery was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery
      @delivery = Delivery.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def delivery_params
      params.require(:delivery).permit(:status, :total, :payin_id, :availability_id, :delivery_request_id, :delivery_contents)
    end
end
