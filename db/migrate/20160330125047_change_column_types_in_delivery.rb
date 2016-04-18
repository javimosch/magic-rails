class ChangeColumnTypesInDelivery < ActiveRecord::Migration
  def change
  	change_column :deliveries, :total, :float
  	change_column :deliveries, :commission, :float
  	change_column :deliveries, :shipping_total, :float
  end
end
