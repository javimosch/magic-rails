json.array!(@orders) do |order|
	json.extract! order, :id
	json.status 'pending'
	json.delivery_request order
	json.buyer order.buyer
	json.deliveryman nil
	json.address order.address
	json.schedule order.schedule
	response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{order.shop_id}", query: {
		mct: ENV['MASTERCOURSE_KEY']
	})
	if response.code == 200
		json.shop response
	end
	json.url delivery_url(order, format: :json)
end
json.array!(@deliveries) do |delivery|
	json.extract! delivery, :id, :status, :validation_code, :total, :commission, :payin_id, :availability_id, :delivery_request_id
	json.delivery_request delivery.delivery_request
	json.buyer delivery.delivery_request.buyer
	json.deliveryman delivery.availability.deliveryman
	json.address delivery.delivery_request.address
	json.availability delivery.availability
	json.schedule delivery.delivery_request.schedule
	response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{delivery.availability.shop_id}", query: {
		mct: ENV['MASTERCOURSE_KEY']
	})
	if response.code == 200
		json.shop response
	end
	json.url delivery_url(delivery, format: :json)
end