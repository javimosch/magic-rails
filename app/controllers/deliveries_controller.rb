class DeliveriesController < BaseController
  before_action :set_delivery, only: [:show, :edit, :update, :destroy, :finalize, :confirm, :cancel]

  # Retourne la liste de toutes les livraisons correspondantes à l'utilisateur actuel.
  #
  # @note GET /deliveries
  # @note GET /deliveries.json
  def index

    @availabilities = Availability.where(deliveryman_id: current_user.id).order(created_at: :desc)
    ids = []
    @availabilities.each do |order|
      ids.push(order.id)
    end
    @deliveries = Delivery.where(availability_id: ids).order(created_at: :desc)
  end

  # Retourne la liste de toutes les commandes correspondantes à l'utilisateur actuel.
  #
  # @note GET /orders
  # @note GET /orders.json
  def orders

    @orders = DeliveryRequest.where('buyer_id = ? AND (match = ? OR (match = ? AND delivery_id IS NULL))', current_user.id, false, true).order(created_at: :desc)
    @deliveries = DeliveryRequest.where(buyer_id: current_user.id, match: true)
    ids = []
    @deliveries.each do |delivery|
      ids.push(delivery.id)
    end
    @deliveries = Delivery.where(delivery_request_id: ids).order(created_at: :desc)

  end

  # Retourne la livraison/commande correspondant au paramètre 1.
  #
  # @note GET /deliveries/1
  # @note GET /deliveries/1.json
  def show
  end

  # Affiche le formulaire de création d'une nouvelle livraison/commande.
  #
  # @note GET /deliveries/new
  def new
    @delivery = Delivery.new
  end

  # Affiche le formulaire d'édition d'une livraison/commande correspondant au paramètre 1.
  #
  # @note GET /deliveries/1/edit
  def edit
  end

  # Créée une nouvelle livraison/commande.
  #
  # @note POST /deliveries
  # @note POST /deliveries.json
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

  # Confirmation de la livraison/commande correspondant au paramètre 1.
  #
  # @note POST /deliveries/1/confirm
  # @note POST /deliveries/1/confirm.json
  def confirm
    respond_to do |format|
      if !@delivery.nil? and (current_user.id == @delivery.delivery_request.buyer_id) and (@delivery.status != 'canceled')
          @contents = DeliveryContent.where(id_delivery: @delivery.id)

          if @contents.count == 0
            format.json { render json: { notice: 'EMPTY_CART' }, status: :unprocessable_entity }
            format.html { render :new }
          else
            Delivery.update(@delivery.id, :status => 'completed')

            @delivery = Delivery.find(@delivery.id)
            meta = @delivery.to_meta(true)

            Notification.create! mode: 'cart_filled', title: 'Votre client a finalisé son panier', content: 'Votre client a finalisé son panier', sender: 'sms', user_id: @delivery.availability.deliveryman_id, meta: meta.to_json, read: false
            format.html { redirect_to @delivery, notice: 'Delivery was successfully confirmed.' }
            format.json { head :no_content }
          end

      else
        format.html { render json: {error: 'TOO_LATE'}, status: :unprocessable_entity }
        format.json { render json: {}, status: :unprocessable_entity }
      end
    end
  end

  # Annulation de la livraison/commande correspondant au paramètre 1.
  #
  # @note POST /deliveries/1/cancel
  # @note POST /deliveries/1/cancel.json
  def cancel
    respond_to do |format|
      if !@delivery.nil? && current_user.id == @delivery.delivery_request.buyer_id
          Delivery.update(@delivery.id, :status => 'canceled')

          @delivery = Delivery.find(@delivery.id)
          meta = @delivery.to_meta(true)

          Notification.create! mode: 'canceled_delivery', title: 'Commande annulée', content: 'Le demandeur a annulé sa demande', sender: 'push', user_id: @delivery.availability.deliveryman_id, meta: meta.to_json, read: false
          Notifier.send_canceled_delivery_request(@delivery.availability.deliveryman, @delivery).deliver_now

          format.html { redirect_to @delivery, notice: 'Delivery was successfully canceled.' }
          format.json { head :no_content }
      else
        format.html { render :new }
        format.json { render json: {}, status: :unprocessable_entity }
      end
    end
  end

  # Finalisation de la livraison/commande correspondant au paramètre 1.
  #
  # @note POST /deliveries/1/finalize
  # @note POST /deliveries/1/finalize.json
  def finalize

    proxy = URI(ENV['FIXIE_URL'])

    respond_to do |format|

      # Le livreur entre le code et note l'acheteur
      if Delivery.exists?(id: params[:id], validation_code: params[:validation_code], status: 'completed') && current_user.id == @delivery.availability.deliveryman_id

        @deliveryman_wallet = @delivery.availability.deliveryman.wallet
        @buyer_wallet = @delivery.delivery_request.buyer.wallet
        @delivery_total = @delivery.total + @delivery.commission

        if @deliveryman_wallet.lemonway_id.present?

          response = HTTParty.post(ENV['LEMONWAY_URL'] + '/MoneyInWithCardId',
            http_proxyaddr: proxy.host,
            http_proxyport: proxy.port,
            http_proxyuser: proxy.user,
            http_proxypass: proxy.password,
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
              wallet: @buyer_wallet.lemonway_id,
              cardId: @buyer_wallet.lemonway_card_id,
              amountTot: '%.2f' % @delivery_total,
              amountCom: '%.2f' % @delivery.commission,
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

            if response['d']['TRANS'].present?

              payment = HTTParty.post(ENV['LEMONWAY_URL'] + '/SendPayment',
                http_proxyaddr: proxy.host,
                http_proxyport: proxy.port,
                http_proxyuser: proxy.user,
                http_proxypass: proxy.password,
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
                  debitWallet: @buyer_wallet.lemonway_id,
                  creditWallet: @deliveryman_wallet.lemonway_id,
                  amount: '%.2f' % @delivery_total,
                  message: @delivery.id,
                  scheduledDate: '',
                  privateData: ''
                }.to_json
              );

              if payment['d']['TRANS_SENDPAYMENT'].present?

                Rating.create!(to_user_id: @delivery.delivery_request.buyer_id, from_user_id: @delivery.availability.deliveryman_id, rating: params[:rating].to_i, delivery_id: @delivery.id)
                Delivery.update(params[:id], payin_id: response['d']['TRANS']['HPAY']['ID'], status: 'done')
                @delivery.availability.update(enabled: false)
                format.html { redirect_to @delivery, notice: 'Delivery was successfully set to finished.' }
                format.json { render json: { notice: 'ORDER_DONE' }, status: :ok }

              elsif response['d']['E'].present?

                ap "LEMONWAY ERROR"
                ap response['d']['E']
                format.html { render :edit }
                format.json { render json: { notice: response['d']['E']['Msg'] }, status: :unprocessable_entity }

              end


            elsif response['d']['E'].present?

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
        @delivery.update(rated: true)
        format.html { render :new }
        format.json { render json: { notice: 'RATING_DONE' }, status: :ok }

      # Mauvais code de validation
      else

        format.html { render :new }
        format.json { render json: { notice: 'VALIDATION_CODE_ERROR' }, status: :unprocessable_entity }

      end

    end
  end

  # Mise à jour de la livraison/commande correspondant au paramètre 1.
  #
  # @note PATCH/PUT /deliveries/1
  # @note PATCH/PUT /deliveries/1.json
  def update

    delivery_contents = params[:delivery_contents]

    if delivery_contents.nil?
      respond_to do |format|
        format.json { render json: { notice: 'EMPTY_CART' }, status: :unprocessable_entity }
        format.html { render :new }
      end
      return
    end

    total = 0
    DeliveryContent.destroy_all(id_delivery: @delivery.id)
    delivery_contents.each do |delivery_content|
      DeliveryContent.create! id_delivery: @delivery.id, id_product: delivery_content[:id_product], quantity: delivery_content[:quantity], unit_price: delivery_content[:unit_price]
      total += delivery_content[:quantity].to_f * delivery_content[:unit_price].to_f
    end

    # Delivery.update(@delivery.id, :total => total)

    respond_to do |format|
      if @delivery.update(total: total)
        format.html { redirect_to @delivery, notice: 'Delivery was successfully updated.' }
        format.json { render :show, status: :ok, location: @delivery }
      else
        format.html { render :edit }
        format.json { render json: @delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # Suppression de l'adresse correspondant au paramètre 1.
  #
  # @note DELETE /deliveries/1
  # @note DELETE /deliveries/1.json
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
    params.require(:delivery).permit(:availability_id, :delivery_request_id, :delivery_contents)
  end
end
