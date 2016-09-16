ActiveAdmin.register Delivery do

	actions :all, :except => [:new, :edit]
	permit_params :total, :commission, :shipping_total

	form do |f|
		f.inputs do
			f.input :total
			f.input :commission
			f.input :shipping_total
			f.input :delivery_request_id
			f.input :availability_id
		end
		f.actions
	end
	
	show do
		attributes_table do
	      row :id
	      row :status
	      row :validation_code
	      row :total
	      row :commission
	      row :payin_id
	      row :availability_id
	      row :delivery_request_id
	      row :created_at
	      row :updated_at
	      row :shipping_total
	      row :rated
	      row :related_products do |delivery|
	          items = DeliveryContent.where({id_delivery:delivery.id})
	          raw(items.to_json)
	      end
	    end
	    active_admin_comments
	end

	action_item only: [:edit] do
		link_to "Set cancelled", set_cancelled_admin_delivery_path
		link_to "Set disabled", set_disabled_admin_delivery_path
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
