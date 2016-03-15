class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :address
      t.string :city
      t.string :zip
      t.string :additional_address

      t.timestamps null: false
    end
  end
end
