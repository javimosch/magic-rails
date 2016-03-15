json.array!(@deliveries) do |delivery|
  json.extract! delivery, :id, :status, :validation_code, :total, :commission, :payin_id, :availability_id, :delivery_request_id
  json.url delivery_url(delivery, format: :json)
end
