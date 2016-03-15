class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|

    	t.belongs_to :user
    	t.string :type
    	t.string :title
    	t.text :content
    	t.string :sender
    	t.string :meta
    	t.boolean :read

		t.timestamps null: false
    end
  end
end
