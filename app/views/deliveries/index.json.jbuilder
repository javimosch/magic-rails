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
end