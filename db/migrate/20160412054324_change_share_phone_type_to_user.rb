class ChangeSharePhoneTypeToUser < ActiveRecord::Migration
  def change
    change_column :users, :share_phone, 'boolean USING false', default: false
  end
end
