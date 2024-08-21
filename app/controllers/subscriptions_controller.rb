class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: %i[ show edit renew renew_update update destroy ]
  before_action :set_activity, only: %i[ new create ]
  before_action :set_users, only: %i[ edit update new create ]

  after_action :update_open, only: %i[ edit renew_update ]


  # GET /subscriptions
  def index
    @pagy, @subscriptions = pagy(
      Subscription
        .all
        .includes(:user, :activity, :activity_plan)
        .load_async
    )
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
    @activity = @subscription.activity
    @plans = @activity.activity_plans
  end

  # POST /subscriptions
  def create
    @subscription = Subscription.build(subscription_params)

    if @subscription.save
      create_open_subscription if params[:open]

      redirect_to new_payment_path(payable_type: 'Subscription', payable_id: @subscription)
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /subscriptions/1/renew
  def renew
    @subscription.start_date = Date.today
    @subscription.end_date = ""

    @activity = @subscription.activity
    @plans = @activity.activity_plans
    @user = User.find(@subscription.user.id)
  end

  # PATCH/PUT /subscriptions/1
  def renew_update
    if @subscription.update(subscription_params)
      @subscription.inactive!
      redirect_to new_payment_path(payable_type: 'Subscription', payable_id: @subscription.id), notice: "L'abbonamento è stato aggiornato correttamente, per attivarlo procedi al pagamento"
    else
      rendere :renew, status: :unprocessable_entity
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

  def update_open
    if params[:open]
      @subscription.open? ? renew_open_subscription : create_open_subscription
    elsif @subscription.open?
      open = @subscription.open_subscription
      @subscription.update(open_subscription: nil)
      open.update(normal_subscription: nil)
      open.destroy
    end
  end

  def renew_open_subscription
    Subscription.transaction do
      sub = @subscription
      open = @subscription.open_subscription

      open.inactive!
      open.start_date = sub.start_date
      open.end_date = sub.end_date

      if open.save!
        @subscription.update!(open_subscription: open)
      else
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback, "Open subscription update failed"
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    # Cattura l'errore di validazione e fornisci un feedback
    logger.error "Failed to renew open subscription: #{e.record.errors.full_messages.join(', ')}"
    render :new, status: :unprocessable_entity
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
      )

      open_subscription.normal_subscription = @subscription

      if open_subscription.save
        @subscription.update(open_subscription_id: open_subscription.id)
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
    params.require(:subscription).permit(:start_date, :end_date, :user_id, :staff_id, :activity_id, :activity_plan_id)
  end
end
