# frozen_string_literal: true

# Subscription Controlle
class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: %i[show edit renew renew_update update destroy]
  before_action :set_activity, only: %i[new create]
  before_action :set_users, only: %i[edit update new create]
  before_action :set_weight_room_activity, only: %i[create renew_update update]

  after_action :update_open, only: %i[update renew_update]

  # GET /subscriptions
  def index
    @pagy, @subscriptions = pagy(Subscription.all.includes(:user, :activity, :activity_plan).load_async)
  end

  # GET /subscriptions/1
  def show; end

  # GET /subscriptions/new
  def new
    @subscription = Subscription.build
    @subscription.start_date = Time.zone.today

    @plans = @activity.activity_plans
  end

  # GET /subscriptions/1/edit
  def edit
    @activity = @subscription.activity
    @plans = @activity.activity_plans
  end

  # POST /subscriptions
  def create
    @subscription = Subscription.build(subscription_params)

    if @subscription.save
      create_open_subscription if params[:open]

      redirect_to new_payment_path(payable_type: 'Subscription', payable_id: @subscription), notice: t('.create_succ')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /subscriptions/1/renew
  def renew
    @subscription.start_date = Time.zone.today
    @subscription.end_date = ''

    @activity = @subscription.activity
    @plans = @activity.activity_plans
    @user = User.find(@subscription.user.id)
  end

  # PATCH/PUT /subscriptions/1
  def renew_update
    if @subscription.update(subscription_params)
      @subscription.inactive!
      redirect_to new_payment_path(payable_type: 'Subscription', payable_id: @subscription.id),
                  notice: t('.renew_succ')
    else
      rendere :renew, status: :unprocessable_entity
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
    @activity = Activity.find(params[:activity_id] || subscription_params[:activity_id])
  end

  def set_users
    @users = User.joins(:membership).where('membership.status' => :active)
                 .where.not(id: Subscription.where(activity: @activity).select(:user_id)).load_async
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
      @subscription.destroy
    end
  end

  # Only allow a list of trusted parameters through.
  def subscription_params
    params.require(:subscription).permit(:start_date, :end_date, :user_id, :staff_id, :activity_id, :activity_plan_id)
  end
end
