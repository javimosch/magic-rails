ActiveAdmin.register Commission do
	actions :all, :except => [:edit, :destroy]
	permit_params :percentage, :shipping_percentage
end
