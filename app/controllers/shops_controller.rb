class ShopsController < BaseController
  include ShopsHelper

  # Retourne la liste de tous les magasins correspondant à l'adresse/position de l'utilisateur actuel.
  #
  # @note GET /shops
  # @note GET /shops.json
  def index

    @response = []
    
    if ENV['MASTERCOURSE_KEY'].nil? then
      logger.debug "WARNING: MASTERCOURSE_KEY Enviromental variable required."
    else

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
      
      logger.debug "MASTERCOURSE RESPONSE #{response}"
    
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

  # Retourne la liste de tous les produits recherchés.
  #
  # @note GET /products
  # @note GET /products.json
  def products

    @response = []
    
    shop_id = params['shop_id']
    
    if ENV['USE_SHOP_ID'] then
      shop_id = ENV['USE_SHOP_ID']
    end
    
    url = "https://www.mastercourses.com/api2/stores/#{shop_id}/products/"
    
    if !Rails.cache.read(url).nil? then 
      if Rails.cache.read(url).is_a? String then
        logger.debug "Bad Cache removed for #{params['shop_id']}"
        Rails.cache.delete(url)
      end 
    end
    
    all_products = Rails.cache.fetch(url, expires_in: 1.days) do
      logger.debug "HTTP GET #{url}"
      HTTParty.get(url, query: {
          mct: ENV['MASTERCOURSE_KEY']
      }, timeout: 120).parsed_response
    end

    valid_products = all_products.find_all { |product| product['available'] and product['price'] and includes_strings?(params['q'], product['label']) }

    valid_products.take(20).each do |product|
      url = "https://www.mastercourses.com/api2/products/#{product['id']}/"
      complete_product = Rails.cache.fetch(url, expires_in: 1.days) do
        HTTParty.get(url, query: {
          mct: ENV['MASTERCOURSE_KEY']
        }).parsed_response
      end
      @response << complete_product.merge(product)
    end

  end

  # Recherche d'une chaine de caractères dans une autre.
  def includes_strings?(words, haystack)
    words.downcase.split(' ').each do |word|
      haystack = ActiveSupport::Inflector.transliterate(haystack)
      unless haystack.downcase.include? ActiveSupport::Inflector.transliterate(word)
        return false
      end
    end
    return true
  end

  # Retourne le magasin correspondant au paramètre 1.
  #
  # @note GET /shops/1
  # @note GET /shops/1.json
  def show
    @response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{params['id']}/", query: {
      mct: ENV['MASTERCOURSE_KEY']
    });
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def shop_params
      params.permit(:lat, :lon, :schedule, :stars)
    end
end
