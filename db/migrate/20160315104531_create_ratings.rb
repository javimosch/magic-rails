class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :to_user_id
      t.integer :from_user_id
      t.integer :rating
      t.string :type

      t.timestamps null: false
    end
  end
end
