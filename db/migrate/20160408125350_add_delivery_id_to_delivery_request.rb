class AddDeliveryIdToDeliveryRequest < ActiveRecord::Migration
  def change
    add_column :delivery_requests, :delivery_id, :integer
  end
end
