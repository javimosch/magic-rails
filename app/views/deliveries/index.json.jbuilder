json.array!(@deliveries) do |delivery|
	json.extract! delivery, :id, :status, :validation_code, :total, :commission, :shipping_total, :rated, :payin_id, :availability_id, :delivery_request_id
	json.delivery_request delivery.delivery_request
	json.buyer delivery.delivery_request.buyer
	json.availability delivery.availability
	json.deliveryman delivery.availability.deliveryman
	json.address delivery.delivery_request.address
	json.schedule delivery.availability.schedule
	json.shop get_shop(delivery.availability.shop_id)
	json.url delivery_url(delivery, format: :json)
	# json.delivery_contents delivery.delivery_contents
	json.delivery_contents do
		json.array!(delivery.delivery_contents) do |delivery_content|
	  	json.extract! delivery_content, :id, :id_delivery, :id_product, :quantity, :unit_price
	  	
	  	shop_id = delivery.availability.shop_id
    
    if ENV['USE_SHOP_ID'] then
      shop_id = ENV['USE_SHOP_ID']
    end
    
	  	
			product_url = "https://www.mastercourses.com/api2/stores/#{shop_id}/products/#{delivery_content.id_product}/"
			product = Rails.cache.fetch(product_url, expires_in: 1.days) do
				HTTParty.get(product_url, query: {
					mct: ENV['MASTERCOURSE_KEY']
				}).parsed_response
			end
			json.product product
	  end
	end
end
