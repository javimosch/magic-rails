class CreateWallets < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.integer :user_id
      t.integer :lemonway_id
      t.string :credit_card_display

      t.timestamps null: false
    end
  end
end
