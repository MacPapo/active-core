class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: %i[ show edit update destroy ]
  before_action :set_activity, only: %i[ edit update new create ]
  before_action :set_users, only: %i[ edit update new create ]


  # GET /subscriptions
  def index
    @subscriptions = Subscription.all.load_async
  end

  # GET /subscriptions/1
  def show
  end

  # GET /subscriptions/new
  def new
    @subscription = Subscription.build
    @subscription.start_date = Date.today

    @plans = @activity.activity_plans
  end

  # GET /subscriptions/1/edit
  def edit
  end

  # POST /subscriptions
  def create
    @subscription = Subscription.build(subscription_params)

    if @subscription.save
      create_open_subscription if @subscription.open?

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

  def set_activity
    @activity = Activity.find(params[:activity_id] || subscription_params[:activity_id])
  end

  def set_users
    @users = User
               .joins(:membership)
               .where('membership.status' => :active)
               .where.not(id: Subscription.where(activity: @activity).select(:user_id))
               .load_async
  end

  def create_open_subscription
    Subscription.transaction do
      weight_room_activity = Activity.find_by(name: 'SALA PESI')
      weight_room_plan = weight_room_activity.activity_plans.find_by(plan: :one_month)

      open_subscription = Subscription.build(
        user_id: subscription_params[:user_id],
        staff_id: subscription_params[:staff_id],
        activity: weight_room_activity,
        activity_plan: weight_room_plan,
        start_date: subscription_params[:start_date],
        open: true
      )

      if open_subscription.save

        linked_subscription = LinkedSubscription.build(
          subscription: @subscription,
          open_subscription: open_subscription
        )

        if linked_subscription.save
          @subscription.update(linked_subscription: linked_subscription)
        else
          @subscription.destroy
          render :new, status: :unprocessable_entity
        end

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
