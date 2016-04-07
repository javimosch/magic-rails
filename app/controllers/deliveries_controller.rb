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

  # POST /payment
  # POST /payment.json
  def payment

    if (Delivery.exists?(id: params[:id], status: 'completed'))

      @delivery = Delivery.where(id: params[:id], status: 'completed').first
      @wallet = @delivery.delivery_request.buyer.wallet

      if !@wallet.lemonway_id.nil? && !@wallet.lemonway_card_id.nil?

        response = HTTParty.post(ENV['LEMONWAY_URL'] + '/MoneyInWithCardId',
          headers: {
            'Content-Type' => 'application/json; charset=utf-8',
          },
          body: {
            wlLogin: ENV['LEMONWAY_LOGIN'],
            wlPass: ENV['LEMONWAY_PASS'],
            language: 'fr',
            version: '1.8',
            walletIp: request.remote_ip,
            walletUa: 'ruby/rails',
            wallet: @wallet.id,
            cardId: @wallet.lemonway_card_id,
            amountTot: @delivery.total,
            amountCom: @delivery.commission,
            comment: @delivery.status,
            message: @delivery.status,
            autoCommission: '0',
            isPreAuth: '',
            specialConfig: '',
            delayedDays: '',
            wkToken: @delivery.id
          }.to_json
        );

        if response.code == 200

          if !response['d']['TRANS']['HPAY'].nil?
            @wallet.update(payin_id: response['d']['TRANS']['HPAY']['ID'], status: 'paid')
            respond_to do |format|
              format.html { redirect_to @wallet, notice: 'Delivery was successfully paid.' }
              format.json { render :show, status: :ok, location: @delivery }
            end
          elsif !response['d']['E'].nil?
            ap "LEMONWAY ERROR"
            ap response['d']['E']
            respond_to do |format|
              format.html { render :edit }
              format.json { render json: { notice: response['d']['E']['Msg'] }, status: :unprocessable_entity }
            end
          end

        else

          respond_to do |format|
            format.html { render :new }
            format.json { render json: { notice: 'LEMONWAY_SERVER_ERROR' }, status: :unprocessable_entity }
          end

        end
      end
    else

      respond_to do |format|
        format.html { render :new }
        format.json { render json: { notice: 'DELIVERY_NOT_FOUND' }, status: :unprocessable_entity }
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
    total = 0
    DeliveryContent.destroy_all(id_delivery: @delivery.id)
    delivery_contents.each do |delivery_content|
      DeliveryContent.create! id_delivery: @delivery.id, id_product: delivery_content[:id_product], quantity: delivery_content[:quantity], unit_price: delivery_content[:unit_price]
      total += delivery_content[:quantity].to_f * delivery_content[:unit_price].to_f
    end

    Delivery.update(@delivery.id, :status => 'completed', :total => total)

    @delivery = Delivery.find(@delivery.id)

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
    params.require(:delivery).permit(:status, :total, :availability_id, :delivery_request_id, :delivery_contents)
  end
end
