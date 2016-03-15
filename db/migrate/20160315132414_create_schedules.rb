class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.string :schedule
      t.timestamp :date

      t.timestamps null: false
    end
  end
end
