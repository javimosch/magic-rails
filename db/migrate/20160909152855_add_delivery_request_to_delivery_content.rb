class AddDeliveryRequestToDeliveryContent < ActiveRecord::Migration
  def change
    add_column :delivery_requests, :delivery_request_id, :integer, default: nil
  end
end
