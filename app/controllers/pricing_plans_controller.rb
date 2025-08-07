class PricingPlansController < ApplicationController
  before_action :set_product
  before_action :set_pricing_plan, only: %i[ edit update destroy ]

  # GET /pricing_plans/new
  def new
    @pricing_plan = @product.pricing_plans.new
  end

  # GET /pricing_plans/1/edit
  def edit
  end

  # POST /pricing_plans or /pricing_plans.json
  def create
    @pricing_plan = @product.pricing_plans.new(pricing_plan_params)

      if @pricing_plan.save
        respond_to do |format|
          format.html { redirect_to @product, notice: "Pricing plan was successfully created." }
          format.turbo_stream
        end
      else
        render :new, status: :unprocessable_entity
      end
  end

  # PATCH/PUT /pricing_plans/1 or /pricing_plans/1.json
  def update
    if @pricing_plan.update(pricing_plan_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @product, notice: "Pricing plan was successfully updated." }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /pricing_plans/1 or /pricing_plans/1.json
  def destroy
    @pricing_plan.discard

    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = "Pricing plan was successfully archived." }
      format.html { redirect_to @product, status: :see_other, notice: "Pricing plan was successfully archived." }
      format.json { head :no_content }
    end
  end

  private
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
