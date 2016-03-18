class ShopsController < ApplicationController

  # GET /shops
  # GET /shops.json
  def index

    @response = []

    response = HTTParty.get('https://www.mastercourses.com/api2/stores/locator', query: {
      mct: ENV['MASTERCOURSE_KEY'],
      lat: params[:lat],
      lon: params[:lon],
      number: ENV['SHOPS_NUMBER']
    });

    if response.code == 200
      @response = response
    end

  end

  # GET /shops/1
  # GET /shops/1.json
  def show
  end

  # GET /shops/new
  def new
  end

  # GET /shops/1/edit
  def edit
  end

  # POST /shops
  # POST /shops.json
  def create
  end

  # PATCH/PUT /shops/1
  # PATCH/PUT /shops/1.json
  def update
  end

  # DELETE /shops/1
  # DELETE /shops/1.json
  def destroy
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def shop_params
      params.permit(:lat, :lon)
    end
end
