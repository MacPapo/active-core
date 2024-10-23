# frozen_string_literal: true

# Subscription Controller
class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: %i[show edit update renew renew_update destroy restore]
  before_action :set_activity, only: %i[create update renew_update]
  before_action :set_plans, only: %i[create update renew_update]
  before_action :set_weight_room_activity, only: %i[create renew_update update]
  before_action :set_user, only: %i[create renew_update]

  after_action :update_open, only: %i[update renew_update]

  # GET /subscriptions
  def index
    @sort_by = params[:sort_by] || 'updated_at'
    @direction = params[:direction] || 'desc'

    filters = {
      visibility: params[:visibility],
      name: params[:name],
      activity: params[:activity_id],
      plan: params[:plan_id],
      open: params[:sub_open],
      from: params[:date_from],
      to: params[:date_to],
      sort_by: @sort_by,
      direction: @direction
    }

    @pagy, @subscriptions = pagy(Subscription.filter(filters).includes(:user, :activity, :activity_plan).load_async)
  end

  # GET /subscriptions/1
  def show; end

  # GET /subscriptions/new
  def new
    @subscription = Subscription.build
    @subscription.start_date = Time.zone.today

    set_user_and_activities(params[:user_id]) if params[:user_id]
    set_activity_and_plan(params[:activity_id]) if params[:activity_id]
  end

  # GET /subscriptions/1/edit
  def edit
    @activity = @subscription.activity
    set_plans(@activity)
  end

  # POST /subscriptions
  def create
    user_id = subscription_params[:user_id]
    begin
      ActiveRecord::Base.transaction do
        @subscription = Subscription.build(subscription_params)

        check_if_user_already_subscribed(user_id)

        if @subscription.save
          if params[:open] && params[:open].to_i == 1
            raise t('.create_duplicate_open') if open_already_exists(user_id)

            create_open_subscription
          end

          redirect_to new_payment_path(eid: @subscription.id, type: 'sub'), notice: t('.create_succ')
        else
          raise t('.create_failed')
        end
      end
    rescue => e
      real_direction = params[:direction]&.to_i
      set_user_and_activities(user_id) if real_direction.zero?
      set_activity_and_plan(subscription_params[:activity_id]) if !real_direction.zero?
      flash.now[:alert] = e
      render :new, status: :unprocessable_entity
    end
  end

  def check_if_user_already_subscribed(id)
    x = @activity.subscriptions.where(user: id)
    raise t('.create_duplicate_user') if x.present?
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
    @subscription.discard
    redirect_to user_url(@subscription.user), notice: t('.destroy_succ')
  end

  # PATCH /users/1
  def restore
    @subscription.undiscard
    redirect_to users_url, notice: t('.restore_succ')
  end

  private

  def set_user_and_activities(uid)
    set_user(uid)
    @activities = Activity.kept
  end

  def set_activity_and_plan(aid)
    @activity = Activity.find(aid)
    set_plans(@activity)
  end

  def set_subscription
    @subscription = Subscription.find(params[:id])
  end

  def set_activity
    @activity ||= Activity.find(params[:activity_id] || subscription_params[:activity_id])
  end

  def set_plans(activity = @activity)
    @plans = activity.activity_plans.kept
  end

  def set_user(uid = subscription_params[:user_id])
    @user = User.find(uid)
  end

  def update_open
    Subscription.transaction do
      if params[:open] && params[:open].to_i == 1
        @subscription.open? ? renew_open_subscription : create_open_subscription
      elsif @subscription.open?
        if @subscription.open_subscription.present?
          @subscription.update(open_subscription: nil)
        else
          @subscription.normal_subscription.update(open_subscription: nil)
        end
      end
    end
  end

  def renew_open_subscription
    open = @subscription.open_subscription

    open.update(
      start_date: @subscription.start_date.beginning_of_month,
      end_date: @subscription.start_date.end_of_month
    )

    raise t('.renew_open_failed') unless open.save
  end

  def set_weight_room_activity
    @weight_room = Activity.find_by(name: 'Sala pesi')
    @weight_plan = @weight_room.activity_plans.find_by(plan: :one_month)
  end

  def create_open_subscription
    return connect_weight_room if weight_room_subscription_already_exists(subscription_params[:user_id])

    open_subscription = Subscription.build(
      user_id: subscription_params[:user_id], normal_subscription: @subscription,
      staff_id: subscription_params[:staff_id], activity: @weight_room,
      activity_plan: @weight_plan, start_date: subscription_params[:start_date]
    )

    if open_subscription.save
      @subscription.update(open_subscription_id: open_subscription.id)
    else
      open_subscription.destroy
      raise t('.create_open_failed')
    end
  end

  def open_already_exists(id)
    User.find(id).has_open_subscription?
  end

  def weight_room_subscription_already_exists(id)
    @weight_room.subscriptions.where(user_id: id).present?
  end

  def connect_weight_room
    weight_room_sub = @user.subscriptions.find_by(activity: Activity.find_by(name: 'Sala pesi'))
    weight_room_plans = weight_room_sub.activity.activity_plans
    plan = weight_room_plans.find_by(plan: :one_month)

    weight_room_sub.update(
      status: @subscription.status,
      activity_plan_id: plan.id,
      start_date: subscription_params[:start_date],
      staff_id: subscription_params[:staff_id]
    )

    if weight_room_sub.save
      @subscription.update(open_subscription_id: weight_room_sub.id)
      @subscription.save
    else
      raise t('.merge_failed')
    end
  end

  # Only allow a list of trusted parameters through.
  def subscription_params
    params.require(:subscription).permit(:start_date, :end_date, :user_id, :staff_id, :activity_id, :activity_plan_id)
  end
end
