# frozen_string_literal: true

# Membership Controller
class OldMembershipsController < ApplicationController
  before_action :set_membership, only: %i[show edit renew renew_update update destroy restore]
  before_action :set_user, only: %i[edit new renew create update renew_update]

  # GET /memberships
  def index
    @sort_by = params[:sort_by] || "updated_at"
    @direction = params[:direction] || "desc"

    filters = {
      visibility: params[:visibility],
      name: params[:name],
      from: params[:date_from],
      to: params[:date_to],
      sort_by: @sort_by,
      direction: @direction
    }

    @pagy, @memberships = pagy(Membership.filter(filters).includes(:user).load_async)
  end

  # GET /memberships/1
  def show; end

  # GET /memberships/new
  def new
    if user_has_membership?
      redirect_to memberships_path, alert: t(".membership_already_registered")
    else
      @membership = Membership.build
      @membership.start_date = Time.zone.today
    end
  end

  # GET /memberships/1/edit
  def edit; end

  # POST /memberships
  def create
    user_id = membership_params[:user_id]
    @membership = Membership.build(membership_params)

    if @membership.save
      redirect_to new_payment_path(eid: @membership.id, type: "mem"), notice: t(".create_succ")
    else
      render :new, user_id:, status: :unprocessable_entity
    end
  end

  def renew
    if @membership.inactive?
      redirect_to users_path, alert: t(".membership_inactive")
    else
      @membership.start_date = Time.zone.today
      @membership.update!(end_date: nil)
    end
  end

  def renew_update
    if @membership.update(membership_params)
      @membership.inactive!
      redirect_to new_payment_path(eid: @membership.id, type: "mem"), notice: t(".renew_succ")
    else
      render :renew, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /memberships/1
  def update
    if @membership.update(membership_params)
      redirect_to @membership, notice: t(".update_succ")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /memberships/1
  def destroy
    @membership.discard
    redirect_to memberships_url, notice: t(".destroy_succ")
  end

  def restore
    @membership.undiscard
    redirect_to memberships_url, notice: t(".restore_succ")
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_membership
    @membership = Membership.find(params[:id])
  end

  def set_user
    @user ||= Member.find(params[:user_id] || membership_params[:user_id])
  end

  def user_has_membership?
    Membership.exists?(user_id: @user.id)
  end

  # Only allow a list of trusted parameters through.
  def membership_params
    params.require(:membership).permit(:start_date, :end_date, :user_id, :staff_id)
  end
end
