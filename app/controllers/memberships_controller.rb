class MembershipsController < ApplicationController
  before_action :set_membership, only: %i[ show edit update destroy ]

  # GET /memberships or /memberships.json
  def index
    @memberships = Membership.all
  end

  # GET /memberships/1 or /memberships/1.json
  def show
  end

  # GET /memberships/new
  def new
    @membership = Membership.new(user_id: params[:user_id], staff_id: params[:staff_id])
  end

  # GET /memberships/1/edit
  def edit
    @membership = Membership.find(params[:id])
    @membership.start_date = Date.today
  end

  # POST /memberships or /memberships.json
  def create
    @membership = Membership.new(membership_params)

    if @membership.save
      redirect_to new_payment_path(payable_type: 'Membership', payable_id: @membership.id, staff_id: current_staff), notice: "La Quota associativa e' stata correttamente creata."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /memberships/1 or /memberships/1.json
  def update
    if @membership.update(membership_params)
      redirect_to new_payment_path(payable_type: 'Membership', payable_id: @membership.id, staff_id: current_staff), notice: "La Quota associativa e' stata correttamente aggiornata."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /memberships/1 or /memberships/1.json
  def destroy
    @membership.destroy!

    respond_to do |format|
      format.html { redirect_to memberships_url, notice: "Membership was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_membership
      @membership = Membership.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def membership_params
      params.require(:membership).permit(:start_date, :user_id, :staff_id)
    end
end
