class RenameTypeToModeInNotification < ActiveRecord::Migration
  def change
  	rename_column :notifications, :type, :mode
  end
end
