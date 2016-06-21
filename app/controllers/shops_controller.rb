class ShopsController < BaseController
  include ShopsHelper
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

      # Use chain name instead of shop name
      response.each do |shop|
        shop['name'] = chain_name(shop['chain_id'].to_s)
      end

      if params[:schedule].present? && params[:stars].present?

        rated_users = []

        User.where('rating_average >= ? OR rating_average IS NULL', params[:stars].to_f).where.not(id: current_user.id).each do |user|
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

        response.each do |shop|
          shop[:count] = 0
          @response.push(shop)
        end

        if (Schedule.exists?(date: @date, schedule: @hours))
          @schedule = Schedule.find_by(date: @date, schedule: @hours)
          @availability = Availability.where("schedule_id = ? AND shop_id IN (?) AND enabled = true AND deliveryman_id IN (?)", @schedule.id, shop_ids, rated_users)
          @availability.each do |availability|
            shop = @response.select {|s| s['id'].to_i == availability.shop_id}.first
            shop[:count] += 1
            end
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

    url = "https://www.mastercourses.com/api2/stores/#{params['shop_id']}/"
    shop = Rails.cache.fetch(url, expires_in: 1.days) do
      HTTParty.get(url, query: {
        mct: ENV['MASTERCOURSE_KEY']
      }).parsed_response
    end

    url = "https://www.mastercourses.com/api2/chains/#{shop['chain_id']}/products/search/"
    searched_products = HTTParty.get(url, query: {
      mct: ENV['MASTERCOURSE_KEY'],
      q: params['q']
    })

    if searched_products.code == 200
      counter = 0
      limit = ENV['PRODUCT_SEARCH_LIMIT'].to_i
      searched_products.each do |searched|
        if counter < limit
          url = "https://www.mastercourses.com/api2/stores/#{shop['id']}/products/#{searched['id']}/"
          product = Rails.cache.fetch(url, expires_in: 1.days) do
            HTTParty.get(url, query: {
              mct: ENV['MASTERCOURSE_KEY']
            }).parsed_response
          end
          if product['available'] and product['price']
            @response << product
            counter += 1
          end
        end
      end
    end

  end

  def includes_strings?(words, haystack)
    words.downcase.split(' ').each do |word|
      haystack = ActiveSupport::Inflector.transliterate(haystack)
      unless haystack.downcase.include? ActiveSupport::Inflector.transliterate(word)
        return false
      end
    end
    return true
  end

  # GET /shops/1
  # GET /shops/1.json
  def show
    @response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{params['id']}/", query: {
      mct: ENV['MASTERCOURSE_KEY']
    });
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
