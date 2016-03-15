class AddAuthFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :auth_method, :string, default: 'email'
    add_column :users, :auth_token, :string, default: nil
  end
end
