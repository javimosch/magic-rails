class AddDeliveryIdToAvailability < ActiveRecord::Migration
  def change
  	add_column :availabilities, :delivery_id, :integer
  end
end
