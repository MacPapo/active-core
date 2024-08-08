class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: %i[ show edit update destroy ]
  before_action :set_user, only: %i[ edit update new create ]
  before_action :set_staff, only: %i[ edit update new create ]
  before_action :set_activities_and_plans, only: %i[ edit new update create]
  before_action :delete_linked_sub, only: [:destroy]

  # GET /subscriptions
  def index
    @subscriptions = Subscription.all
  end

  # GET /subscriptions/1
  def show
  end

  # GET /subscriptions/new
  def new
    @subscription = @user.subscriptions.build
  end

  # GET /subscriptions/1/edit
  def edit
  end

  # POST /subscriptions
  def create
    @subscription = @user.subscriptions.build(subscription_params)
    # @subscription.staff = @staff TODO

    if @subscription.save
      create_open_subscription if @subscription.open?

      # redirect_to @user, notice: 'Subscription was successfully created.'
      redirect_to new_payment_path(payable_type: 'Subscription', payable_id: @subscription)
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /subscriptions/1
  def update
    if @subscription.update(subscription_params)
      redirect_to subscription_url(@subscription), notice: "Subscription was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /subscriptions/1
  def destroy
    user = @subscription.user
    @subscription.destroy!

    redirect_to user_url(user), notice: "Subscription was successfully destroyed."
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_subscription
    @subscription = Subscription.find(params[:id])
  end

  def set_user
    @user = User.find(params[:user_id] || subscription_params[:user_id])
  end

  def set_staff
    @staff = Staff.find(params[:staff_id] || subscription_params[:staff_id])
  end

  def delete_linked_sub
    return unless @subscription.open? && @subscription.linked_subscription

    lsub = @subscription.linked_subscription
    lsub.update(linked_subscription_id: nil)
    @subscription.update(linked_subscription_id: nil)
    lsub.destroy!
  end

  def set_activities_and_plans
    @activities = Activity.all
    @activity_plans = ActivityPlan.all
  end

  def create_open_subscription
    Subscription.transaction do
      weight_room_activity = Activity.find_by(name: 'SALA PESI')
      weight_room_plan = weight_room_activity.activity_plans.find_by(plan: :one_month)

      linked_subscription = @user.subscriptions.build(
        activity: weight_room_activity,
        activity_plan: weight_room_plan,
        start_date: @subscription.start_date,
        staff: @subscription.staff,
        open: true,
        linked_subscription: @subscription
      )

      if linked_subscription.save
        @subscription.update(linked_subscription: linked_subscription)
      else
        @subscription.destroy
        render :new, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::Rollback
    render :new, status: :unprocessable_entity
  end

  # Only allow a list of trusted parameters through.
  def subscription_params
    params.require(:subscription).permit(:start_date, :end_date, :user_id, :staff_id, :activity_id, :activity_plan_id, :open)
  end
end
