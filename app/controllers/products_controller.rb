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
    # Qui potrai vedere i dettagli del prodotto e, in futuro,
    # aggiungere la gestione dei suoi PricingPlan.
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
      redirect_to @product, notice: "Prodotto creato con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1
  def update
    if @product.update(product_params)
      redirect_to @product, notice: "Prodotto aggiornato con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /products/1
  def destroy
    # Usiamo .discard invece di .destroy per il soft-delete!
    @product.discard
    redirect_to products_url, notice: "Prodotto archiviato con successo."
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
