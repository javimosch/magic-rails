json.extract! @delivery, :id, :status, :validation_code, :total, :commission, :rated, :payin_id, :availability_id, :delivery_request_id, :created_at, :updated_at, :delivery_contents
json.delivery_contents do
  json.array!(@delivery.delivery_contents) do |delivery_content|
    json.extract! delivery_content, :id, :id_delivery, :id_product, :quantity, :unit_price
    response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{@delivery.availability.shop_id}/products/#{delivery_content.id_product}/", query: {
      mct: ENV['MASTERCOURSE_KEY']
    });
    if response.code == 200
      json.product response
    end
  end
end
