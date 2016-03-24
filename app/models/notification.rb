class Notification < ActiveRecord::Base

	belongs_to :user

	after_create :send_notification

	private

	def send_notification

	    if self.sender == 'email'
	    	ap 'Send email'
	    elsif self.sender == 'push'
	    	ap 'Send push'
	    elsif self.sender == 'sms'
	    	ap 'Send sms'
	    end
	end


end
