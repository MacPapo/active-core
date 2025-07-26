# frozen_string_literal: true

# PricingPlans Controller
class PricingPlansController < ApplicationController
  before_action :authorize_admin!

  before_action :set_product
  before_action :set_pricing_plan, only: [ :edit, :update, :destroy ]

  def new
    @pricing_plan = @product.pricing_plans.build
  end

  def create
    @pricing_plan = @product.pricing_plans.build(pricing_plan_params)

    if @pricing_plan.save
      redirect_to @product, notice: "Piano di prezzo creato con successo!"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @pricing_plan.update(pricing_plan_params)
      redirect_to [ @product, @pricing_plan ], notice: "Piano di prezzo aggiornato."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @pricing_plan.discard

    redirect_to @product, notice: "Piano di prezzo eliminato."
  end

  private

  def set_product
    @product = Product.kept.find(params[:product_id])
  end

  def set_pricing_plan
    @pricing_plan = @product.pricing_plans.kept.find(params[:id])
  end

  def pricing_plan_params
    params.require(:pricing_plan).permit(:duration_type, :duration_value, :price, :affiliated_price, :valid_from, :valid_until, :active)
  end
end
