# frozen_string_literal: true

# Membership Controller
class MembershipsController < ApplicationController
  before_action :set_membership, only: %i[show edit renew renew_update update destroy]
  before_action :set_user, only: %i[edit new create update renew_update]

  # GET /memberships
  def index
    @pagy, @memberships = pagy(Membership.all.includes(:user).load_async)
  end

  # GET /memberships/1
  def show; end

  # GET /memberships/new
  def new
    @membership = Membership.build
    @membership.start_date = Time.zone.today
  end

  # GET /memberships/1/edit
  def edit; end

  # POST /memberships
  def create
    user_id = membership_params[:user_id]
    @membership = Membership.build(membership_params)

    if @membership.save
      redirect_to new_payment_path(payable_type: 'Membership', payable_id: @membership.id),
                  notice: t('.create_succ')
    else
      render :new, user_id:, status: :unprocessable_entity
    end
  end

  def renew
    @membership.start_date = Time.zone.today
    @membership.end_date = ''
  end

  def renew_update
    if @membership.update(membership_params)
      @membership.inactive!
      redirect_to new_payment_path(payable_type: 'Membership', payable_id: @membership.id),
                  notice: t('.renew_succ')
    else
      render :renew, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /memberships/1
  def update
    if @membership.update(membership_params)
      redirect_to membership_path(@membership),
                  notice: t('.update_succ')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /memberships/1
  def destroy
    @membership.destroy!

    redirect_to memberships_url, notice: t('.destroy_succ')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_membership
    @membership = Membership.find(params[:id])
  end

  def set_user
    @user ||= User.find(params[:user_id] || membership_params[:user_id])
  end

  # Only allow a list of trusted parameters through.
  def membership_params
    params.require(:membership).permit(:start_date, :end_date, :user_id, :staff_id)
  end
end
