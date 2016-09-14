class Notifier < ApplicationMailer
  default from: ENV['ADMIN_EMAIL'],
          bcc: ENV['BCC_ADMIN_EMAIL']

  # Envoie le mail de bienvenue.
  #
  # @param user [Object] Informations sur l'utilisateur
  def send_registration(user)
    @user = user

    mail to: user.email, subject: "Bienvenue dans l'aventure Shopmycourses !"
  end

  # Envoie le mail de rappel pour le remplissage du panier.
  #
  # @param user [Object] Informations sur l'utilisateur
  # @param delivery_request [Object] Demande de livraison
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

  # Envoie le mail pour une nouvelle livraison disponible.
  #
  # @param user [Object] Informations sur l'utilisateur
  # @param delivery_request [Object] Demande de livraison
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

    mail to: user.email, subject: "Demande de livraison"
  end

  # Envoie le mail pour l'annulation d'une commande.
  #
  # @param user [Object] Informations sur l'utilisateur
  # @param delivery [Object] Demande de livraison
  # @param timeout [Boolean] Définit si la notification est déliverée en différé
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

  # Envoie le mail pour l'annulation d'une livraison.
  #
  # @param user [Object] Informations sur l'utilisateur
  # @param delivery [Object] Demande de livraison
  # @param timeout [Boolean] Définit si la notification est déliverée en différé
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
