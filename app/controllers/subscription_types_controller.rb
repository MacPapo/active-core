class SubscriptionTypesController < ApplicationController
  before_action :set_subscription_type, only: %i[ show edit update destroy ]

  # GET /subscription_types or /subscription_types.json
  def index
    @subscription_types = SubscriptionType.all
  end

  # GET /subscription_types/1 or /subscription_types/1.json
  def show
  end

  # GET /subscription_types/new
  def new
    @subscription_type = SubscriptionType.new
  end

  # GET /subscription_types/1/edit
  def edit
  end

  # POST /subscription_types or /subscription_types.json
  def create
    @subscription_type = SubscriptionType.new(subscription_type_params)

    respond_to do |format|
      if @subscription_type.save
        format.html { redirect_to subscription_type_url(@subscription_type), notice: "Subscription type was successfully created." }
        format.json { render :show, status: :created, location: @subscription_type }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @subscription_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subscription_types/1 or /subscription_types/1.json
  def update
    respond_to do |format|
      if @subscription_type.update(subscription_type_params)
        format.html { redirect_to subscription_type_url(@subscription_type), notice: "Subscription type was successfully updated." }
        format.json { render :show, status: :ok, location: @subscription_type }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @subscription_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subscription_types/1 or /subscription_types/1.json
  def destroy
    @subscription_type.destroy!

    respond_to do |format|
      format.html { redirect_to subscription_types_url, notice: "Subscription type was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subscription_type
      @subscription_type = SubscriptionType.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def subscription_type_params
      params.require(:subscription_type).permit(:desc, :duration, :cost)
    end
end
