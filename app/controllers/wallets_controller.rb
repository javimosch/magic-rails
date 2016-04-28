class WalletsController < BaseController
  before_action :set_wallet, only: [:edit, :destroy]
  before_action :set_user_wallet, only: [:show, :update]

  # GET /wallets
  # GET /wallets.json
  def index
    @wallets = Wallet.all
  end

  # GET /wallets/1
  # GET /wallets/1.json
  def show
  end

  # GET /wallets/new
  def new
    @wallet = Wallet.new
  end

  # GET /wallets/1/edit
  def edit
  end

  # PATCH/PUT /wallets/1
  # PATCH/PUT /wallets/1.json
  def update

    proxy = URI(ENV['FIXIE_URL'])

    response = HTTParty.post(ENV['LEMONWAY_URL'] + '/RegisterCard',
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
        wallet: @wallet.lemonway_id,
        cardType: params[:card][:type],
        cardNumber: params[:card][:number],
        cardCode: params[:card][:cvv],
        cardDate: params[:card][:date],
        specialConfig: ''
      }.to_json
    );

    if response.code == 200
      if !response['d']['CARD'].nil?
        @wallet.update(credit_card_display: response['d']['CARD']['EXTRA']['NUM'].gsub(/(.{4})(?=.)/, '\1 \2'), lemonway_card_id: response['d']['CARD']['ID'])
        respond_to do |format|
          format.html { redirect_to @wallet, notice: 'Wallet was successfully updated.' }
          format.json { render :show, status: :ok, location: @wallet }
        end
      elsif !response['d']['E'].nil?
        respond_to do |format|
          format.html { render :edit }
          format.json { render json: { notice: response['d']['E']['Msg'] }, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: { notice: 'LEMONWAY_SERVER_ERROR' }, status: :unprocessable_entity }
      end
    end

  end

  # DELETE /wallets/1
  # DELETE /wallets/1.json
  def destroy
    @wallet.destroy
    respond_to do |format|
      format.html { redirect_to wallets_url, notice: 'Wallet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wallet
      @wallet = Wallet.find(params[:id])
    end

    def set_user_wallet
      @wallet = User.find(params[:id]).wallet
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wallet_params
      params.require(:wallet).permit(:user_id, :card)
    end
end
