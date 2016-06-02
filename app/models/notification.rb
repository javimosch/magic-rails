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
				ap "Send sms to #{self.user.phone}"
        sms = "#{self.title}\nRendez-vous sur l'appli: http://goo.gl/HHnGdx"
        result = SinchSms.send(ENV["SINCH_KEY"], ENV["SINCH_SECRET"], sms, self.user.phone)
				ap "SINCH RESULT :"
				ap result
			end
	end

end
