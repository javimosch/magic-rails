ActiveAdmin.register DeliveryRequest do

  permit_params :buyer_id, :schedule_id, :shop_id, :address_attributes

  index do
    column :id
    column :buyer
    column :schedule
    column :shop_id
    column :match
    actions
  end

  show do
		attributes_table do
      row :id
      row :buyer
      row :schedule
      row :shop_id
      row :address do |delivery_request|
        raw("#{delivery_request.address.address} - #{delivery_request.address.additional_address}<br>
            #{delivery_request.address.zip} #{delivery_request.address.city}")
      end
      row :created_at
      row :updated_at
      row :match
      row :delivery
    end
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :buyer_id, label: 'Acheteur'
      f.input :schedule_id, as: :select, collection: Schedule.all.map{ |s| ["#{s.date.strftime('%d/%m/%Y')} #{s.schedule}", s.id] }, label: 'Plage horaire'
      f.input :shop_id, label: 'Identifiant du magasin'
      if f.object.new_record?
        f.inputs "Addresse de l'acheteur" do
          f.semantic_fields_for :address_attributes do |address|
            address.input :address
            address.input :city
            address.input :zip
            address.input :additional_address
          end
        end
      end
    end
    f.actions
  end

  controller do

    def create

      request = params[:delivery_request]

      @address = Address.new(address: request[:address_attributes][:address], city: request[:address_attributes][:city], zip: request[:address_attributes][:zip], additional_address: request[:address_attributes][:additional_address])
      if @address.save
        @delivery_request = DeliveryRequest.create! buyer_id: request[:buyer_id], schedule_id: request[:schedule_id], shop_id: request[:shop_id], address_id: @address.id
        if @delivery_request.save
          Address.update(@address.id, delivery_request_id: @delivery_request.id)
          respond_to do |format|
            format.html { redirect_to admin_delivery_requests_path, notice: 'La demande de livraison a bien été crée.' }
          end
        end
      end

    end
  end

end
