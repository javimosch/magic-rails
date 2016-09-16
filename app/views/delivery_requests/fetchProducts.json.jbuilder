json.array!(@delivery_contents) do |delivery_content|
	json.extract! delivery_content, :id, :quantity, :unit_price
	
	shop_id = @delivery_request.shop_id
    
    if ENV['USE_SHOP_ID'] then
      shop_id = ENV['USE_SHOP_ID']
    end
    
	
	product_url = "https://www.mastercourses.com/api2/stores/#{shop_id}/products/#{delivery_content.id_product}/"
	logger.debug "PRODUCT_URL #{product_url}"
	product = Rails.cache.fetch(product_url, expires_in: 1.days) do
		HTTParty.get(product_url, query: {
			mct: ENV['MASTERCOURSE_KEY']
		}).parsed_response
	end
	json.product product
end