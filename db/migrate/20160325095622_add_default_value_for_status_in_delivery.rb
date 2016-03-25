class AddDefaultValueForStatusInDelivery < ActiveRecord::Migration
  def change
  	change_column_default :deliveries, :status, 'pending'
  end
end
