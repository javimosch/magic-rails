class AddDeliveryIdToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :delivery_id, :integer
  end
end
