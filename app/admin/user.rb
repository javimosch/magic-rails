ActiveAdmin.register User do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if resource.something?
#   permitted
# end

	index do
		column :email
		column :firstname
		column :lastname
		column :phone
		column :share_phone
		column :rating_average
		column 'Total deliveries' do |user|
			user.count_deliveries
		end
		actions
	end

end
