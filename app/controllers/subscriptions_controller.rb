# frozen_string_literal: true

# Subscription Controller
class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: %i[show edit update renew renew_update destroy]
  before_action :set_activity, only: %i[new create update renew_update]
  before_action :set_plans, only: %i[new create update renew_update]
  before_action :set_weight_room_activity, only: %i[create renew_update update]

  after_action :update_open, only: %i[update renew_update]

  # GET /subscriptions
  def index
    @pagy, @subscriptions = pagy(
      Subscription
        .filter(params[:name], params[:surname], params[:direction])
        .includes(:user, :activity, :activity_plan)
        .load_async
    )
  end

  # GET /subscriptions/1
  def show; end

  # GET /subscriptions/new
  def new
    @subscription = Subscription.build
    @subscription.start_date = Time.zone.today
  end

  # GET /subscriptions/1/edit
  def edit
    @activity = @subscription.activity
    set_plans(@activity)
  end

  # POST /subscriptions
  def create
    activity_id = subscription_params[:activity_id]
    begin
      @subscription = Subscription.build(subscription_params)
      @subscription.save!
      Subscription.transaction { create_open_subscription } if params[:open]

      redirect_to new_payment_path(payable_type: 'Subscription', payable_id: @subscription), notice: t('.create_succ')
    rescue ActiveRecord::RecordInvalid => e
      @subscription = e.record
      render :new, activity_id:, status: :unprocessable_entity
    end
  end

  # GET /subscriptions/1/renew
  def renew
    if @subscription.inactive?
      redirect_to users_path, alert: t('.subscription_already_inactive')
    else
      @subscription.start_date = Time.zone.today
      @subscription.end_date = ''
      @activity = @subscription.activity
      set_plans(@activity)
      @user = User.find(@subscription.user.id)
    end
  end

  # PATCH/PUT /subscriptions/1
  def renew_update
    if @subscription.update(subscription_params)
      @subscription.inactive!
      redirect_to new_payment_path(payable_type: 'Subscription', payable_id: @subscription.id), notice: t('.renew_succ')
    else
      render :renew, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /subscriptions/1
  def update
    if @subscription.update(subscription_params)
      redirect_to subscription_url(@subscription), notice: t('.update_succ')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /subscriptions/1
  def destroy
    user = @subscription.user
    @subscription.destroy!

    redirect_to user_url(user), notice: t('.destroy_succ')
  end

  private

  def set_subscription
    @subscription = Subscription.find(params[:id])
  end

  def set_activity
    @activity ||= Activity.find(params[:activity_id] || subscription_params[:activity_id])
  end

  def set_plans(activity = @activity)
    @plans = activity.activity_plans
  end

  def update_open
    if params[:open]
      Subscription.transaction { @subscription.open? ? renew_open_subscription : create_open_subscription }
    elsif @subscription.open?
      open = @subscription.open_subscription
      @subscription.update(open_subscription: nil)
      open.destroy
    end
  end

  def renew_open_subscription
    @subscription.open_subscription.update!(
      status: :inactive, start_date: @subscription.start_date.beginning_of_month,
      end_date: @subscription.start_date.end_of_month
    )
  end

  def set_weight_room_activity
    @weight_room = Activity.find_by(name: 'SALA PESI')
    @weight_plan = @weight_room.activity_plans.find_by(plan: :one_month)
  end

  def create_open_subscription
    open_subscription = Subscription.build(
      user_id: subscription_params[:user_id], normal_subscription: @subscription,
      staff_id: subscription_params[:staff_id], activity: @weight_room,
      activity_plan: @weight_plan, start_date: subscription_params[:start_date]
    )

    if open_subscription.save
      @subscription.update(open_subscription_id: open_subscription.id)
    else
      open_subscription.destroy
      raise ActiveRecord::RecordInvalid.new(open_subscription)
    end
  end

  # Only allow a list of trusted parameters through.
  def subscription_params
    params.require(:subscription).permit(:start_date, :end_date, :user_id, :staff_id, :activity_id, :activity_plan_id)
  end
end
