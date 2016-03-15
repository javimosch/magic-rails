class CreateWallets < ActiveRecord::Migration
	def change
		create_table :wallets do |t|

			t.belongs_to :user
			t.integer :lemonway_id
			t.string :credit_card_display

			t.timestamps null: false
		end
	end
end
