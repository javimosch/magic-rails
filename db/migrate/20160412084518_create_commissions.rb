class CreateCommissions < ActiveRecord::Migration
  def change
    create_table :commissions do |t|
    	t.float :percentage
    	t.float :shipping_percentage

		t.timestamps null: false
    end
  end
end
