class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: %i[ show edit update destroy ]

  # GET /subscriptions
  def index
    @subscriptions = Subscription.all
  end

  # GET /subscriptions/1
  def show
  end

  # GET /subscriptions/new
  def new
    @subscription = Subscription.new
  end

  # GET /subscriptions/1/edit
  def edit
  end

  # POST /subscriptions
  def create
    # TODO update this
    user = User.find(subscription_params[:user_id])
    activity = Activity.find(subscription_params[:activity_id])
    activity_plan = ActivityPlan.find(subscription_params[:activity_plan_id])

    p subscription_params[:open]
    if subscription_params[:open] == 'true'
      open_activity = Activity.find_by(name: 'Sala Pesi')
      open_plan = open_activity.activity_plans.find_by(plan: :one_month)

      course_subscription, open_subscription = Subscription.create_open_subscription(
        user,
        current_staff,
        activity,
        activity_plan,
        open_activity,
        open_plan,
        subscription_params[:start_date],
        subscription_params[:end_date]
      )

      if course_subscription && open_subscription
        redirect_to new_payment_path(payable_type: 'Subscription', payable_id: course_subscription.id, staff: current_staff), notice: "L'iscrizione è andata a buon fine."
      else
        render :new, status: :unprocessable_entity
      end

    else

      @subscription = Subscription.new(subscription_params)

      if @subscription.save
        redirect_to new_payment_path(payable_type: 'Subscription', payable_id: @subscription.id, staff: current_staff), notice: "L'iscrizione è andata a buon fine."
      else
        render :new, status: :unprocessable_entity
      end
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
    @subscription.destroy!

    redirect_to subscriptions_url, notice: "Subscription was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subscription
      @subscription = Subscription.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def subscription_params
      params.require(:subscription).permit(:start_date, :end_date, :user_id, :staff_id, :activity_id, :activity_plan_id, :open)
    end
end
