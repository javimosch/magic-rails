class Schedule < ActiveRecord::Base

	attr_accessor :was_created

	has_many :availabilities

	def expired?
		if self.date.to_date < Date.today
			ap "date < today"
			return true
		elsif self.date.to_date == Date.today
			ap "date == today"
			expire_time = Time.parse("#{self.schedule[-3..-2]}:00")
			return expire_time < Time.now
		else
			ap "date > today"
			return false
		end
	end
end
