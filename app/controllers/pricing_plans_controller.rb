class PricingPlansController < ApplicationController
  before_action :set_product
  before_action :set_pricing_plan, only: %i[ edit update destroy ]

  def new
    @pricing_plan = @product.pricing_plans.new
  end

  def edit
  end

  def create
    @pricing_plan = @product.pricing_plans.new(pricing_plan_params)

    if @pricing_plan.save
      flash.now[:notice] = "Pricing Plan creato con successo!" # todo localize
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @pricing_plan.update(pricing_plan_params)
      flash.now[:notice] = "Pricing Plan aggiornato con successo!" # todo localize
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @pricing_plan.discard

    flash.now[:notice] = "Pricing Plan archiviato con successo!" # TODO localize
  end

  private
    # Set product
    def set_product
      @product = Product.find(params[:product_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_pricing_plan
      @pricing_plan = @product.pricing_plans.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def pricing_plan_params
      params.require(:pricing_plan).permit(:name, :price, :affiliated_price,
                                           :duration_interval, :duration_unit,
                                           :valid_from, :valid_until)
    end
end
