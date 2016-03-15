json.array!(@addresses) do |address|
  json.extract! address, :id, :address, :city, :zip, :additional_address
  json.url address_url(address, format: :json)
end
