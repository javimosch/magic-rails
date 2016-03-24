class AddWaletIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :wallet_id, :integer
  end
end
