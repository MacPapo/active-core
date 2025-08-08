class ProductsController < ApplicationController
  # Questo metodo trova il prodotto specifico prima di azioni come show, edit, update, destroy
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products
  def index
    # Mostra solo i prodotti non "scartati"
    @products = Product.kept.order(:name)
  end

  # GET /products/1
  def show
    @pricing_plans = @product.pricing_plans.kept
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  def create
    @product = Product.new(product_params)

    if @product.save
      flash.now[:notice] = "Prodotto creato con successo!" # TODO localize
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      flash.now[:notice] = "Prodotto aggiornato con successo!" # TODO localize
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /products/1
  def destroy
    # Usiamo .discard invece di .destroy per il soft-delete!
    @product.discard

    flash.now[:notice] = "Prodotto archiviato con successo!" # TODO localize
  end

  private
    # Metodo per trovare il prodotto
    def set_product
      @product = Product.find(params[:id])
    end

    # Definisce i parametri "sicuri" che possono essere accettati dal form
    def product_params
      params.require(:product).permit(:name, :description, :requires_medical_certificate, :max_capacity)
    end
end
