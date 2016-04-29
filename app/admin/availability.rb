ActiveAdmin.register Availability do

  permit_params :deliveryman_id, :schedule_id, :shop_id, :enabled
  
  form do |f|
		f.inputs do
			f.input :deliveryman, label: 'Livreur'
			f.input :schedule, as: :select, collection: Schedule.all.map{ |s| ["#{s.date.strftime('%d/%m/%Y')} #{s.schedule}", s.id] }, label: 'Plage horaire'
      f.input :shop_id, label: 'Identifiant du magasin'
      f.input :enabled, label: 'Activer cette disponibilité'
    end
		f.actions
	end

end
