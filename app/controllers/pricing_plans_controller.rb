class PricingPlansController < ApplicationController
  before_action :set_pricing_plan, only: %i[ show edit update destroy ]

  # GET /pricing_plans or /pricing_plans.json
  def index
    @pricing_plans = PricingPlan.all
  end

  # GET /pricing_plans/1 or /pricing_plans/1.json
  def show
  end

  # GET /pricing_plans/new
  def new
    @pricing_plan = PricingPlan.new
  end

  # GET /pricing_plans/1/edit
  def edit
  end

  # POST /pricing_plans or /pricing_plans.json
  def create
    @pricing_plan = PricingPlan.new(pricing_plan_params)

    respond_to do |format|
      if @pricing_plan.save
        format.html { redirect_to @pricing_plan, notice: "Pricing plan was successfully created." }
        format.json { render :show, status: :created, location: @pricing_plan }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @pricing_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pricing_plans/1 or /pricing_plans/1.json
  def update
    respond_to do |format|
      if @pricing_plan.update(pricing_plan_params)
        format.html { redirect_to @pricing_plan, notice: "Pricing plan was successfully updated." }
        format.json { render :show, status: :ok, location: @pricing_plan }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @pricing_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pricing_plans/1 or /pricing_plans/1.json
  def destroy
    @pricing_plan.destroy!

    respond_to do |format|
      format.html { redirect_to pricing_plans_path, status: :see_other, notice: "Pricing plan was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pricing_plan
      @pricing_plan = PricingPlan.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def pricing_plan_params
      params.fetch(:pricing_plan, {})
    end
end
