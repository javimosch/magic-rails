class AddDeliveryRequestIdToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :delivery_request_id, :integer
  end
end
