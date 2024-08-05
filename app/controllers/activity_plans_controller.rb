# frozen_string_literal: true

class ActivityPlansController < ApplicationController
  before_action :set_activity_plan, only: %i[ edit update destroy ]

  # GET /activity_plans/new
  def new
    @activity_plan = ActivityPlan.new(activity_id: params[:activity_id])
  end

  # GET /activity_plans/1/edit
  def edit
  end

  # POST /activity_plans
  def create
    @activity_plan = ActivityPlan.new(activity_plan_params)
    if @activity_plan.save
      redirect_to activity_path(@activity_plan.activity), notice: "Il piano è stato correttamente creato."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /activity_plans/1
  def update
    if @activity_plan.update(activity_plan_params)
      redirect_to activity_path(@activity_plan.activity), notice: "Il piano è stato correttamente aggiornato."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /activity_plans/1
  def destroy
    actv = @activity_plan.activity
    @activity_plan.destroy!

    redirect_to activity_path(actv), notice: "Activity_Plan was successfully destroyed."
  end

  private

  def set_activity_plan
    @activity_plan = ActivityPlan.find(params[:id])
  end

  def activity_plan_params
    params.require(:activity_plan).permit(:plan, :cost, :affiliated_cost, :activity_id)
  end
end
