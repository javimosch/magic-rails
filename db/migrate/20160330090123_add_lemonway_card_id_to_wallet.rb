class AddLemonwayCardIdToWallet < ActiveRecord::Migration
  def change
    add_column :wallets, :lemonway_card_id, :integer, default: nil
  end
end
