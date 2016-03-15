json.array!(@delivery_contents) do |delivery_content|
  json.extract! delivery_content, :id, :id_delivery, :id_product, :quantity, :unit_price
  json.url delivery_content_url(delivery_content, format: :json)
end
