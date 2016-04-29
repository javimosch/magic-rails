ActiveAdmin.register Schedule do

  actions :all, :except => [:edit]
  permit_params :schedule, :date

  form do |f|
    f.inputs do
      f.input :date
      f.input :schedule, label: 'Horaires', as: :select, collection: ['08h - 10h', '10h - 12h', '12h - 14h', '14h - 16h', '16h - 18h', '18h - 20h', '20h - 22h']
    end
    f.actions
  end

end
