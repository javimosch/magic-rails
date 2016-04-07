json.array!(@deliveries) do |delivery|
	json.extract! delivery, :id, :status, :validation_code, :total, :commission, :payin_id, :availability_id, :delivery_request_id
	json.delivery_request delivery.delivery_request
	json.buyer delivery.delivery_request.buyer
	json.availability delivery.availability
	json.deliveryman delivery.availability.deliveryman
	json.address delivery.delivery_request.address
	json.schedule delivery.availability.schedule
	response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{delivery.availability.shop_id}", query: {
		mct: ENV['MASTERCOURSE_KEY']
	})
	if response.code == 200
		json.shop response
	end
	json.url delivery_url(delivery, format: :json)
	# json.delivery_contents delivery.delivery_contents
	json.delivery_contents do
		json.array!(delivery.delivery_contents) do |delivery_content|
	  	json.extract! delivery_content, :id, :id_delivery, :id_product, :quantity, :unit_price
			response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{delivery.availability.shop_id}/products/#{delivery_content.id_product}/", query: {
				mct: ENV['MASTERCOURSE_KEY']
			});
			if response.code == 200
				json.product response
			end
	  end
	end
end
