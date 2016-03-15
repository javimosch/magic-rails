class CreateAvailabilities < ActiveRecord::Migration
  def change
    create_table :availabilities do |t|
      t.integer :schedule_id
      t.integer :shop_id
      t.integer :deliveryman_id
      t.boolean :enabled

      t.timestamps null: false
    end
  end
end
