class AddressesController < BaseController
  before_action :set_address, only: [:show, :edit, :update, :destroy]

  # Retourne la liste de toutes les adresses.
  #
  # @note GET /addresses
  # @note GET /addresses.json
  def index
    @addresses = Address.all
  end

  # Retourne l'adresse correspondant au paramètre 1.
  #
  # @note GET /addresses/1
  # @note GET /addresses/1.json
  def show
  end


  # Affiche le formulaire de création d'une nouvelle adresse.
  #
  # @note GET /addresses/new
  def new
    @address = Address.new
  end

  # Affiche le formulaire d'édition de l'adresse correspondant au paramètre 1.
  #
  # @note GET /addresses/1/edit
  def edit
  end

  # Créée une nouvelle adresse.
  #
  # @note POST /addresses
  # @note POST /addresses.json
  def create
    @address = Address.new(address_params)

    respond_to do |format|
      if @address.save
        format.html { redirect_to @address, notice: 'Address was successfully created.' }
        format.json { render :show, status: :created, location: @address }
      else
        format.html { render :new }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  # Mise à jour de l'adresse correspondant au paramètre 1.
  #
  # @note PATCH/PUT /addresses/1
  # @note PATCH/PUT /addresses/1.json
  def update
    respond_to do |format|
      if @address.update(address_params)
        format.html { redirect_to @address, notice: 'Address was successfully updated.' }
        format.json { render :show, status: :ok, location: @address }
      else
        format.html { render :edit }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end

  # Suppression de l'adresse correspondant au paramètre 1.
  #
  # @note DELETE /addresses/1
  # @note DELETE /addresses/1.json
  def destroy
    @address.destroy
    respond_to do |format|
      format.html { redirect_to addresses_url, notice: 'Address was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_address
      @address = Address.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def address_params
      params.require(:address).permit(:address, :city, :zip, :additional_address)
    end
end
