class RemoveTypeFromRating < ActiveRecord::Migration
  def change
  	remove_column :ratings, :type
  end
end
