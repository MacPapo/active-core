# frozen_string_literal: true

# Activity Plans Controller
class ActivityPlansController < ApplicationController
  before_action :set_activity_plan, only: %i[edit update destroy restore]
  before_action :set_activity, only: %i[new]

  # GET /activity_plans/new
  def new
    @activity_plan = @activity.activity_plans.build
    @plans = ActivityPlan.humanize_plans(ActivityPlan.plans.keys - @activity.activity_plans.pluck(:plan))
  end

  # GET /activity_plans/1/edit
  def edit
    @activity = @activity_plan.activity

    # Take all unused plans and the current plan
    used_plans = @activity.activity_plans.pluck(:plan) - [ @activity_plan.plan ]
    @plans = ActivityPlan.humanize_plans(ActivityPlan.plans.keys - used_plans)
  end

  # POST /activity_plans
  def create
    @activity_plan = ActivityPlan.new(activity_plan_params)

    if @activity_plan.save
      redirect_to activity_path(@activity_plan.activity), notice: t(".create_succ")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /activity_plans/1
  def update
    if @activity_plan.update(activity_plan_params)
      redirect_to activity_path(@activity_plan.activity), notice: t(".update_succ")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /activity_plans/1
  def destroy
    @activity_plan.discard
    redirect_to activity_path(@activity_plan.activity), notice: t(".destroy_succ")
  end

  def restore
    @activity_plan.undiscard
    redirect_to activities_url, notice: t(".restore_succ")
  end

  private

  def set_activity_plan
    @activity_plan = ActivityPlan.find(params[:id])
  end

  def set_activity
    @activity = Activity.find(params[:activity_id])
  end

  def activity_plan_params
    params.require(:activity_plan).permit(:plan, :cost, :affiliated_cost, :activity_id)
  end
end
