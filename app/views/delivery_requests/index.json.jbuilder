json.array!(@delivery_requests) do |delivery_request|
  json.extract! delivery_request, :id, :buyer_id, :schedule_id, :shop_id, :address_id
  json.url delivery_request_url(delivery_request, format: :json)
end
