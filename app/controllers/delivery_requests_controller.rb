class DeliveryRequestsController < ApplicationController
  before_action :set_delivery_request, only: [:show, :edit, :update, :destroy]

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

      date = Date.parse(params[:schedule][0]).beginning_of_day()
      @schedule = Schedule.find_by(date: date, schedule: params[:schedule][1])

      if (@schedule.count > 0)

        @address = Address.new(params[:address_attributes])
        if @address.save

          @delivery_request = DeliveryRequest.create! buyer_id: params[:buyer_id], schedule: @schedule.id, shop_id: params[:shop_id], address_id: @address.id
          if @delivery_request.save
            respond_to do |format|
              format.html { redirect_to @delivery_request, notice: 'Delivery request was successfully created.' }
              format.json { render :show, status: :created, location: @delivery_request }
            end
          end

        end

      else

        respond_to do |format|
          format.html { redirect_to @delivery_request, notice: 'Aucun livreur n\'est disponible pour ce créneau de livraison.' }
          format.json { render json: {notice: 'Aucun livreur n\'est disponible pour ce créneau de livraison.' } }
        end

      end

    end

    respond_to do |format|
      format.html { render :new }
      format.json { render json: {notice: 'Veuillez rensigner un créneau valide.'}, status: :unprocessable_entity }
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
