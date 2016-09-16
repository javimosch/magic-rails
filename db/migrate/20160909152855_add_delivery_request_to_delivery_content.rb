class AddDeliveryRequestToDeliveryContent < ActiveRecord::Migration
  def change
    add_column :delivery_contents, :delivery_request_id, :integer, default: nil
  end
end
