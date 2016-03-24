class DeliveryContentsController < BaseController
  before_action :set_delivery_content, only: [:show, :edit, :update, :destroy]

  # GET /delivery_contents
  # GET /delivery_contents.json
  def index
    @delivery_contents = DeliveryContent.all
  end

  # GET /delivery_contents/1
  # GET /delivery_contents/1.json
  def show
  end

  # GET /delivery_contents/new
  def new
    @delivery_content = DeliveryContent.new
  end

  # GET /delivery_contents/1/edit
  def edit
  end

  # POST /delivery_contents
  # POST /delivery_contents.json
  def create
    @delivery_content = DeliveryContent.new(delivery_content_params)

    respond_to do |format|
      if @delivery_content.save
        format.html { redirect_to @delivery_content, notice: 'Delivery content was successfully created.' }
        format.json { render :show, status: :created, location: @delivery_content }
      else
        format.html { render :new }
        format.json { render json: @delivery_content.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /delivery_contents/1
  # PATCH/PUT /delivery_contents/1.json
  def update
    respond_to do |format|
      if @delivery_content.update(delivery_content_params)
        format.html { redirect_to @delivery_content, notice: 'Delivery content was successfully updated.' }
        format.json { render :show, status: :ok, location: @delivery_content }
      else
        format.html { render :edit }
        format.json { render json: @delivery_content.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /delivery_contents/1
  # DELETE /delivery_contents/1.json
  def destroy
    @delivery_content.destroy
    respond_to do |format|
      format.html { redirect_to delivery_contents_url, notice: 'Delivery content was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery_content
      @delivery_content = DeliveryContent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def delivery_content_params
      params.require(:delivery_content).permit(:id_delivery, :id_product, :quantity, :unit_price)
    end
end
