class AddMatchToDeliveryRequest < ActiveRecord::Migration
  def change
    add_column :delivery_requests, :match, :boolean, default: false
  end
end
