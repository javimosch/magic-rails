class AddShippingTotalToDelivery < ActiveRecord::Migration
  def change
    add_column :deliveries, :shopping_total, :integer, default: nil
  end
end
