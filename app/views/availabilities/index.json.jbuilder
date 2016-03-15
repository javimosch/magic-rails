json.array!(@availabilities) do |availability|
  json.extract! availability, :id, :schedule_id, :shop_id, :deliveryman_id, :enabled
  json.url availability_url(availability, format: :json)
end
