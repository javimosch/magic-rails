json.array!(@orders) do |order|
	json.status order.schedule.expired? ? 'canceled' : 'pending'
	json.delivery_request order
	json.buyer order.buyer
	json.deliveryman nil
	json.address order.address
	json.schedule order.schedule
	json.shop get_shop(order.shop_id)
	json.url delivery_url(order, format: :json)
end
json.array!(@deliveries) do |delivery|
	json.extract! delivery, :id, :status, :validation_code, :total, :commission, :shipping_total, :rated, :payin_id, :availability_id, :delivery_request_id
	json.delivery_request delivery.delivery_request
	json.buyer delivery.delivery_request.buyer
	json.deliveryman !delivery.availability.blank? ? delivery.availability.deliveryman : nil
	json.address delivery.delivery_request.address
	json.availability delivery.availability
	json.schedule delivery.delivery_request.schedule
	json.buyer_rating delivery.buyer_rating
	json.shop get_shop(delivery.availability.shop_id)
	json.delivery_contents do
		json.array!(delivery.delivery_contents) do |delivery_content|
	  	json.extract! delivery_content, :id, :id_delivery, :id_product, :quantity, :unit_price
			product_url = "https://www.mastercourses.com/api2/stores/#{delivery.availability.shop_id}/products/#{delivery_content.id_product}/"
			product = Rails.cache.fetch(product_url, expires_in: 1.days) do
				HTTParty.get(product_url, query: {
					mct: ENV['MASTERCOURSE_KEY']
				}).parsed_response
			end
			json.product product
	  end
	end
	json.url delivery_url(delivery, format: :json)
end
