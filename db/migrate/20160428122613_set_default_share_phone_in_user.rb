class SetDefaultSharePhoneInUser < ActiveRecord::Migration
  def change
    change_column :users, :share_phone, :boolean, default: true
  end
end
