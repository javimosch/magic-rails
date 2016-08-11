class Notification < ActiveRecord::Base

	belongs_to :user

	after_create :send_notification

	private

	# Envoie un sms après la création de la notification si elle est de type sms.
	#
	# @!method send_notification
	# @!scope class
	# @!visibility public
	def send_notification

	    if self.sender == 'email'
	    	ap 'Send email'
	    elsif self.sender == 'push'
	    	ap 'Send push'
	    elsif self.sender == 'sms' || self.sender == 'onlysms'
				ap "Send sms to #{self.user.phone}"
        sms = "#{self.title}\nRendez-vous sur l'appli: http://goo.gl/VPv3ZH\nShopmycourses."
				phone = PhonyRails.normalize_number(self.user.phone, country_code: 'FR')
				result = HTTParty.post(ENV['OCTOPUSH_URL'], body: {
					user_login: ENV['OCTOPUSH_LOGIN'],
					api_key: ENV['OCTOPUSH_KEY'],
					sms_recipients: phone,
					sms_text: sms,
					sms_type: ENV['OCTOPUSH_TYPE'],
					sms_sender: 'SMC App',
					transactional: 1
				})
				ap "OCTOPUSH RESULT :"
				ap result
			end
	end

end
