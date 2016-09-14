class NotificationsController < BaseController
  before_action :set_notification, only: [:show, :edit, :update, :destroy]

  # Retourne la liste de toutes les notifications correspondantes à l'utilisateur actuel.
  #
  # @note GET /notifications
  # @note GET /notifications.json
  def index
    @notifications = Notification.where(user_id: current_user.id, read: false, sender: ['push', 'sms'])
  end

  # Retourne la notification correspondant au paramètre 1.
  #
  # @note GET /notifications/1
  # @note GET /notifications/1.json
  def show
  end

  # Affiche le formulaire de création d'une nouvelle notification.
  #
  # @note GET /notifications/new
  def new
    @notification = Notification.new
  end


  # Affiche le formulaire d'édition de la notification correspondant au paramètre 1.
  #
  # @note GET /notifications/1/edit
  def edit
  end

  # Créée une nouvelle notification.
  #
  # @note POST /notifications
  # @note POST /notifications.json
  def create
    @notification = Notification.new(notification_params)

    respond_to do |format|
      if @notification.save
        format.html { redirect_to @notification, notice: 'Notification was successfully created.' }
        format.json { render :show, status: :created, location: @notification }
      else
        format.html { render :new }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # Mise à jour de la notification correspondant au paramètre 1.
  #
  # @note PATCH/PUT /notifications/1
  # @note PATCH/PUT /notifications/1.json
  def update
    respond_to do |format|
      if @notification.update(notification_params)
        format.html { redirect_to @notification, notice: 'Notification was successfully updated.' }
        format.json { render :show, status: :ok, location: @notification }
      else
        format.html { render :edit }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # Suppression de la notification correspondant au paramètre 1.
  #
  # @note DELETE /notifications/1
  # @note DELETE /notifications/1.json
  def destroy
    @notification.destroy
    respond_to do |format|
      format.html { redirect_to notifications_url, notice: 'Notification was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notification
      @notification = Notification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notification_params
      params.require(:notification).permit(:mode, :title, :content, :sender, :user_id, :meta, :read)
    end
end
