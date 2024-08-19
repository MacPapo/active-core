class MembershipsController < ApplicationController
  before_action :set_membership, only: %i[ show edit update destroy ]
  before_action :set_user, only: %i[ edit new create ]

  # GET /memberships
  def index
    @pagy, @memberships = pagy(
      Membership
        .all
        .includes(:user)
        .load_async
    )
  end

  # GET /memberships/1
  def show
  end

  # GET /memberships/new
  def new
    @membership = @user.build_membership
  end

  # GET /memberships/1/edit
  def edit
    @membership = Membership.find(params[:id])
    @membership.start_date = Date.today
  end

  # POST /memberships
  def create
    @membership = @user.build_membership(membership_params)

    if @membership.save
      # TODO translate
      redirect_to new_payment_path(payable_type: 'Membership', payable_id: @membership.id), notice: "La Quota associativa è stata correttamente creata."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /memberships/1
  def update
    if @membership.update(membership_params)
      redirect_to new_payment_path(payable_type: 'Membership', payable_id: @membership.id, staff_id: current_staff), notice: "La Quota associativa è stata correttamente aggiornata."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /memberships/1
  def destroy
    @membership.destroy!

    redirect_to memberships_url, notice: "Membership was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_membership
      @membership = Membership.find(params[:id])
    end

    def set_user
      @user = User.find(params[:user_id] || membership_params[:user_id])
    end

    # Only allow a list of trusted parameters through.
    def membership_params
      params.require(:membership).permit(:start_date, :user_id, :staff_id)
    end
end
