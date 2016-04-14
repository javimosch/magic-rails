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

	action_item only:[:edit] do
		link_to "Set cancelled", set_cancelled_admin_order_path
		link_to "Set disabled", set_disabled_admin_order_path
		link_to "Cancel", resource_path
	end

	member_action :set_cancelled, method: :get do
		resource.update status: 'cancelled'
		redirect_to resource_path, notice: "Delivery was successfully updated."
	end

	member_action :set_disabled, method: :get do
		resource.update status: 'disabled'
		redirect_to resource_path, notice: "Delivery was successfully updated."
	end

end
