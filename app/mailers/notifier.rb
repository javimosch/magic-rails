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

  def send_cart_reminder(user)
    @user = user

    mail to: user.email, subject: "Rappel"
  end
end
