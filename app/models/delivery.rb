class Delivery < ActiveRecord::Base

	belongs_to :delivery_request
	has_many :delivery_contents

end
