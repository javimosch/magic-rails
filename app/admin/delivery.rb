ActiveAdmin.register Delivery do

	permit_params :total, :commission, :shipping_total

	form do |f|
		f.inputs do
			f.input :total
			f.input :commission
			f.input :shipping_total
		end
		f.actions
	end

end
