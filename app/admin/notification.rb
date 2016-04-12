ActiveAdmin.register Notification do

	permit_params :title, :content, :read

	index do
		column :id
		column :mode
		column :title
		column :sender
		column :read
		column :created_at
		column :updated_at
		actions
	end

	show do
		attributes_table do
			row :id
			row :mode
			row :title
			row :content
			row :sender
			row :meta
			row :read
			row :created_at
			row :updated_at
		end
	end

	form do |f|
		f.inputs do
			f.input :title
			f.input :content
			f.input :read
		end
		f.actions
	end

	csv do
		column :id
		column :mode
		column :title
		column :sender
		column :read
		column :created_at
		column :updated_at
	end

end
