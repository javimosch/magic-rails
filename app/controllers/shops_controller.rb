class ShopsController < BaseController

  # GET /shops
  # GET /shops.json
  def index

    @response = []

    if params[:address].present? && !params[:address].blank?
      response = HTTParty.get('https://www.mastercourses.com/api2/stores/locator', query: {
        mct: ENV['MASTERCOURSE_KEY'],
        address: params[:address],
        number: ENV['SHOPS_NUMBER']
      });
    else
      response = HTTParty.get('https://www.mastercourses.com/api2/stores/locator', query: {
        mct: ENV['MASTERCOURSE_KEY'],
        lat: params[:lat],
        lon: params[:lon],
        number: ENV['SHOPS_NUMBER']
      });
    end

    if response.code == 200

      if params[:schedule].present? && params[:stars].present?

        rated_users = []

        User.where('rating_average >= ? OR rating_average IS NULL', params[:stars].to_f).each do |user|
          rated_users.push(user.id)
        end

        shop_ids = []
        response.each do |shop|
          shop_ids.push(shop['id'])
        end

        JSON.parse(params[:schedule]).each do |schedule|
          schedule[1].each do |hours|
            @date = Date.parse(schedule[0]).beginning_of_day
            @hours = hours
          end
        end

        if (Schedule.exists?(date: @date, schedule: @hours))

          @schedule = Schedule.find_by(date: @date, schedule: @hours)
          @availability = Availability.where("schedule_id = ? AND shop_id IN (?) AND enabled = true AND deliveryman_id IN (?) AND delivery_id IS NULL", @schedule.id, shop_ids, rated_users)
          @availability.each do |availability|
            response.each do |shop|
              if availability.shop_id == shop['id'].to_i
                @response.push(shop)
              end
            end
          end

          count = Hash.new(0);
          newResponse = []
          @response.each do |shop|
            count[shop['id'].to_i] += 1
          end

          count.each do |shop_id, v|
            shop = @response.select {|s| s['id'].to_i == shop_id}.first
            ap shop
            shop[:count] = v.to_i
            newResponse.push(shop)
          end
          @response = newResponse
        end
      else
        @response = response
      end

    end

  end

  # GET /products
  # GET /products.json
  def products
    @response = []

    url = "https://www.mastercourses.com/api2/stores/#{params['shop_id']}/products/"
    all_products = Rails.cache.fetch(url, expires_in: 30.days) do
      HTTParty.get(url, query: {
        mct: ENV['MASTERCOURSE_KEY']
      }).parsed_response
    end

    valid_products = all_products.find_all { |product| product['available'] and product['price'] and includes_strings?(params['q'], product['label']) }

    valid_products.take(8).each do |product|
      url = "https://www.mastercourses.com/api2/products/#{product['id']}/"
      complete_product = Rails.cache.fetch(url, expires_in: 30.days) do
        HTTParty.get(url, query: {
          mct: ENV['MASTERCOURSE_KEY']
        }).parsed_response
      end
      @response << complete_product
    end
  end

  def includes_strings?(words, haystack)
    words.downcase.split(' ').each do |word|
      unless haystack.downcase.include? word
        return false
      end
    end
    return true
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
      params.permit(:lat, :lon, :schedule, :stars)
    end
end
