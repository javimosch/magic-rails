class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :type
      t.string :title
      t.text :content
      t.string :sender
      t.integer :user_id
      t.string :meta
      t.boolean :read

      t.timestamps null: false
    end
  end
end
