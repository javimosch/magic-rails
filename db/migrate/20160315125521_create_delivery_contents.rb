class CreateDeliveryContents < ActiveRecord::Migration
  def change
    create_table :delivery_contents do |t|
      t.integer :id_delivery
      t.integer :id_product
      t.integer :quantity
      t.float :unit_price

      t.timestamps null: false
    end
  end
end
