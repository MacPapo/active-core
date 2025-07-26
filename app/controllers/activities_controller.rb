# frozen_string_literal: true

# Activity Controller
class ActivitiesController < ApplicationController
  before_action :set_activity, only: %i[show edit update destroy restore]

  # GET /activities
  def index
    @max = Activity.kept.joins(:subscriptions).group(:activity_id).count.values.max || 0

    @sort_by = params[:sort_by] || "updated_at"
    @direction = params[:direction] || "desc"

    filters = {
      visibility: params[:visibility],
      name: params[:name],
      range: params[:participants_range],
      number: params[:max_participants],
      sort_by: @sort_by,
      direction: @direction
    }

    @pagy, @activities = pagy(Activity.filter(filters).includes(:subscriptions).load_async)
  end

  # GET /activities/1
  def show
    @pagy, @subs = pagy(
      @activity
        .subscriptions
        .load_async
    )

    filters = { visibility: params[:visibility] }

    @count = @subs.count
    @limit = @activity.num_participants
    @plans = @activity.pfilter(filters)
  end

  # GET /activities/:id/plans
  def plans
    activity = Activity.find(params[:id])
    @plans = activity.activity_plans.kept

    render json: { plans: @plans.map { |plan| { id: plan.id, name: plan.humanize_plan } } }
  rescue ActiveRecord::RecordNotFound
    render json: { error: t(".act_not_found") }, status: :not_found
  end

  # GET /activities/new
  def new
    @activity = Activity.new
  end

  # GET /activities/1/edit
  def edit; end

  # POST /activities
  def create
    @activity = Activity.new(activity_params)

    if @activity.save
      redirect_to new_activity_plan_path(activity_id: @activity.id), notice: t(".create_succ")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /activities/1
  def update
    if @activity.update(activity_params)
      redirect_to activity_url(@activity), notice: t(".update_succ")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /activities/1
  def destroy
    @activity.discard
    redirect_to activities_url, notice: t(".destroy_succ")
  end

  # PATCH /activities/1/restore
  def restore
    @activity.undiscard
    redirect_to activities_url, notice: t(".restore_succ")
  end

  # GET /activities/1/name
  def name
    render json: { name: Activity.find(params[:id])&.name }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_activity
    @activity = Activity.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def activity_params
    params.require(:activity).permit(:name, :num_participants)
  end
end
