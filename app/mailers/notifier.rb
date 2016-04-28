class Notifier < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifier.send_notification.subject
  #

  def send_registration(user)
    @user = user

    mail to: user.email, subject: "Bienvenue !"
  end

  def send_cart_reminder(user, delivery_request)
    @user = user
    @schedule = delivery_request.schedule.schedule
    @limit = @schedule.split('-')[0]

    mail to: user.email, subject: "Rappel"
  end

  def send_new_delivery(user, delivery_request)
    @user = user
    @buyer = delivery_request.buyer
    @schedule = delivery_request.schedule
    @shop = nil
    response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{delivery_request.shop_id}", query: {
      mct: ENV['MASTERCOURSE_KEY']
    })
    if response.code == 200
      @shop = JSON.parse(response.body)
    end

    mail to: user.email, subject: "Nouvelle demande de livraison"
  end

  def send_canceled_delivery_request(user, delivery)
    @user = user
    @buyer = delivery.delivery_request.buyer
    @schedule = delivery.delivery_request.schedule
    @shop = nil
    response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{delivery.delivery_request.shop_id}", query: {
      mct: ENV['MASTERCOURSE_KEY']
    })
    if response.code == 200
      @shop = JSON.parse(response.body)
    end

    mail to: user.email, subject: "Annulation de commande"
  end

  def send_canceled_delivery_availability(user, delivery)
    @user = user
    @deliveryman = delivery.availability.deliveryman
    @schedule = delivery.availability.schedule
    @shop = nil
    response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{delivery.delivery_request.shop_id}", query: {
      mct: ENV['MASTERCOURSE_KEY']
    })
    if response.code == 200
      @shop = JSON.parse(response.body)
    end

    mail to: user.email, subject: "Annulation de livraison"
  end
end
