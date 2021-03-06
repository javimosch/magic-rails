class RatingsController < BaseController
  before_action :set_rating, only: [:show, :edit, :update, :destroy]

  # Retourne la liste de toutes les notes.
  #
  # @note GET /ratings
  # @note GET /ratings.json
  def index
    @ratings = Rating.all
  end

  # Retourne la note correspondant au paramètre 1.
  #
  # @note GET /ratings/1
  # @note GET /ratings/1.json
  def show
  end

  # Affiche le formulaire de création d'une nouvelle note.
  #
  # @note GET /ratings/new
  def new
    @rating = Rating.new
  end

  # Affiche le formulaire d'édition de la note correspondant au paramètre 1.
  #
  # @note GET /ratings/1/edit
  def edit
  end

  # Créée une nouvelle note.
  #
  # @note POST /ratings
  # @note POST /ratings.json
  def create
    @rating = Rating.new(rating_params)

    respond_to do |format|
      if @rating.save
        format.html { redirect_to @rating, notice: 'Rating was successfully created.' }
        format.json { render :show, status: :created, location: @rating }
      else
        format.html { render :new }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # Mise à jour de la note correspondant au paramètre 1.
  #
  # @note PATCH/PUT /ratings/1
  # @note PATCH/PUT /ratings/1.json
  def update
    respond_to do |format|
      if @rating.update(rating_params)
        format.html { redirect_to @rating, notice: 'Rating was successfully updated.' }
        format.json { render :show, status: :ok, location: @rating }
      else
        format.html { render :edit }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # Suppression de l'adresse correspondant au paramètre 1.
  #
  # @note DELETE /ratings/1
  # @note DELETE /ratings/1.json
  def destroy
    @rating.destroy
    respond_to do |format|
      format.html { redirect_to ratings_url, notice: 'Rating was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rating
      @rating = Rating.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rating_params
      params.require(:rating).permit(:to_user_id, :from_user_id, :rating)
    end
end
