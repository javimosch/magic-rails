class AddRatedToDelivery < ActiveRecord::Migration
  def change
    add_column :deliveries, :rated, :boolean, default: false
  end
end
