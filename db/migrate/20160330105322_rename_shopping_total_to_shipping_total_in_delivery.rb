class RenameShoppingTotalToShippingTotalInDelivery < ActiveRecord::Migration
  def change
  	rename_column :deliveries, :shopping_total, :shipping_total
  end
end
