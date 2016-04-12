ActiveAdmin.register User do

	permit_params :email, :firstname, :lastname, :phone, :share_phone

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

	show do
		attributes_table do
			row :id
			row :email
			row :firstname
			row :lastname
			row :phone
			row :share_phone
			row :rating_average
			row 'Total deliveries' do |user|
				user.count_deliveries
			end
			row :created_at
			row :updated_at
			row :sign_in_count
			row :last_sign_in_at
		end
	end

	form do |f|
		f.inputs do
			f.input :email
			f.input :firstname
			f.input :lastname
			f.input :phone
			f.input :share_phone
			f.input :current_sign_in_ip, as: :hidden
			f.input :last_sign_in_ip, as: :hidden
		end
		f.actions
	end

	csv do
		column :email
		column :firstname
		column :lastname
		column :phone
		column :share_phone
		column :rating_average
		column 'Total deliveries' do |user|
			user.count_deliveries
		end
	end

end
