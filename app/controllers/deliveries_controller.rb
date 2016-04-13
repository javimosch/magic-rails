class DeliveriesController < BaseController
  before_action :set_delivery, only: [:show, :edit, :update, :destroy, :finalize]

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
        Availability.update(@delivery.availability_id, delivery_id: @delivery.id)
        DeliveryRequest.update(@delivery.delivery_request_id, delivery_id: @delivery.id)
        format.html { redirect_to @delivery, notice: 'Delivery was successfully created.' }
        format.json { render :show, status: :created, location: @delivery }
      else
        format.html { render :new }
        format.json { render json: @delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /deliveries/1/finalize
  # POST /deliveries/1/finalize.json
  def finalize

    respond_to do |format|

      # Le livreur entre le code et note le livré
      if Delivery.exists?(id: params[:id], validation_code: params[:validation_code], status: 'completed') && current_user.id == @delivery.availability.deliveryman_id

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
              Rating.create!(to_user_id: @delivery.delivery_request.buyer_id, from_user_id: @delivery.availability.deliveryman_id, rating: params[:rating].to_i)
              Delivery.update(params[:id], payin_id: response['d']['TRANS']['HPAY']['ID'], status: 'done')
              format.html { redirect_to @delivery, notice: 'Delivery was successfully set to finished.' }
              format.json { render json: { notice: 'ORDER_DONE' }, status: :ok }
            elsif !response['d']['E'].nil?
              ap "LEMONWAY ERROR"
              ap response['d']['E']
              format.html { render :edit }
              format.json { render json: { notice: response['d']['E']['Msg'] }, status: :unprocessable_entity }
            end

          else

            format.html { render :new }
            format.json { render json: { notice: 'LEMONWAY_SERVER_ERROR' }, status: :unprocessable_entity }

          end

        else

          format.html { render :new }
          format.json { render json: { notice: 'WALLET_ERROR' }, status: :unprocessable_entity }

        end

      # Le livré note le livreur
      elsif params[:rating].present? && current_user.id == @delivery.delivery_request.buyer_id

        Rating.create!(to_user_id: @delivery.availability.deliveryman_id, from_user_id: @delivery.delivery_request.buyer_id, rating: params[:rating].to_i, delivery_id: @delivery.id)
        format.html { render :new }
        format.json { render json: { notice: 'RATING_DONE' }, status: :ok }

      # Mauvais code de validation
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
        @delivery_request = @delivery.delivery_request
        @delivery_availability = @delivery.availability
        meta = {}

        meta[:availability] = @delivery_availability
        meta[:delivery_request] = @delivery_request
        meta[:delivery] = @delivery
        meta[:buyer] = @delivery_request.buyer
        meta[:address] = @delivery_request.address
        meta[:schedule] = @delivery_request.schedule
        meta[:shop] = nil

        Notification.create! mode: 'cart_filled', title: 'Votre client a finalisé son panier', content: 'Votre client a finalisé son panier', sender: 'push', user_id: @delivery_availability.deliveryman_id, meta: meta.to_json, read: false

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
    params.require(:delivery).permit(:total, :availability_id, :delivery_request_id, :delivery_contents)
  end
end
