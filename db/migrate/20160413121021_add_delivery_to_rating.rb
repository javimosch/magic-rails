class AddDeliveryToRating < ActiveRecord::Migration
  def change
  	add_column :ratings, :delivery_id, :integer
  end
end
