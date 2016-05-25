json.array!(@availabilities) do |availability|
	json.extract! availability, :id, :schedule_id, :shop_id, :deliveryman_id, :enabled, :delivery
	json.schedule availability.schedule
	response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{availability.shop_id}", query: {
		mct: ENV['MASTERCOURSE_KEY']
	})
	if response.code == 200
		json.shop response
	end
	json.url availability_url(availability, format: :json)
end
