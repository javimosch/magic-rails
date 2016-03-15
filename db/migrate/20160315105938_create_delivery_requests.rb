class CreateDeliveryRequests < ActiveRecord::Migration
  def change
    create_table :delivery_requests do |t|
      t.integer :buyer_id
      t.integer :schedule_id
      t.integer :shop_id
      t.integer :address_id

      t.timestamps null: false
    end
  end
end
