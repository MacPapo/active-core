# frozen_string_literal: true

# Activity Controller
class ActivitiesController < ApplicationController
  before_action :set_activity, only: %i[show edit update destroy]

  # GET /activities
  def index
    @pagy, @activities = pagy(
      Activity
        .filter(params[:name], params[:num], params[:direction])
        .includes(:subscriptions)
        .load_async
    )
  end

  # GET /activities/1
  def show
    @pagy, @subs = pagy(
      @activity
        .subscriptions
        .load_async
    )
  end

  # GET /activities/:id/plans
  def plans
    activity = Activity.find(params[:id])
    plans = activity.activity_plans

    render json: { plans: plans.map { |plan| { id: plan.id, name: plan.humanize_plan } } }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Attività non trovata' }, status: :not_found
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
      redirect_to activity_url(@activity), notice: 'Activity was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /activities/1
  def update
    if @activity.update(activity_params)
      redirect_to activity_url(@activity), notice: 'Activity was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /activities/1
  def destroy
    @activity.destroy!

    redirect_to activities_url, notice: 'Activity was successfully destroyed.'
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
