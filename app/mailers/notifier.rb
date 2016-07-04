class Notifier < ApplicationMailer

  def send_registration(user)
    @user = user

    mail to: user.email, subject: "Bienvenue dans l'aventure Shopmycourses !"
  end

  def send_cart_reminder(user, delivery_request)
    @user = user
    @schedule = delivery_request.schedule.schedule
    @schedule = delivery_request.schedule
    @shop = nil
    response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{delivery_request.shop_id}", query: {
      mct: ENV['MASTERCOURSE_KEY']
    })
    if response.code == 200
      @shop = JSON.parse(response.body)
    end

    mail to: user.email, subject: "Rappel de commande Shopmycourses"
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

    mail to: user.email, subject: "Rappel de livraison Shopmycourses"
  end

  def send_canceled_delivery_request(user, delivery, timeout = false)
    @user = user
    @buyer = delivery.delivery_request.buyer
    @schedule = delivery.delivery_request.schedule
    @shop = nil
    @timeout = timeout
    response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{delivery.delivery_request.shop_id}", query: {
      mct: ENV['MASTERCOURSE_KEY']
    })
    if response.code == 200
      @shop = JSON.parse(response.body)
    end

    mail to: user.email, subject: "Annulation de commande Shopmycourses"
  end

  def send_canceled_delivery_availability(user, delivery, timeout = false)
    @user = user
    @deliveryman = delivery.availability.deliveryman
    @schedule = delivery.availability.schedule
    @shop = nil
    @timeout = timeout
    response = HTTParty.get("https://www.mastercourses.com/api2/stores/#{delivery.delivery_request.shop_id}", query: {
      mct: ENV['MASTERCOURSE_KEY']
    })
    if response.code == 200
      @shop = JSON.parse(response.body)
    end

    mail to: user.email, subject: "Annulation de livraison Shopmycourses"
  end
end
