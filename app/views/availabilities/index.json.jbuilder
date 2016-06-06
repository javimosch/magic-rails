json.array!(@availabilities) do |availability|
	json.extract! availability, :id, :schedule_id, :shop_id, :deliveryman_id, :enabled, :delivery
	json.schedule availability.schedule
	json.shop get_shop(availability.shop_id)
	json.url availability_url(availability, format: :json)
end
