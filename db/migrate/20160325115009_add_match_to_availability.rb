class AddMatchToAvailability < ActiveRecord::Migration
  def change
    add_column :availabilities, :match, :boolean, default: false
  end
end
