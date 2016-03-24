class SetRatingAverageDefaultToNil < ActiveRecord::Migration
  def change
  	change_column_default :users, :rating_average, nil
  end
end
