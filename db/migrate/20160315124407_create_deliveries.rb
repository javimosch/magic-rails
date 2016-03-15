class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.string :status
      t.string :validation_code
      t.integer :total
      t.integer :commission
      t.integer :payin_id
      t.integer :availability_id
      t.integer :delivery_request_id

      t.timestamps null: false
    end
  end
end
