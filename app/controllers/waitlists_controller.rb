# frozen_string_literal: true

# WaitList Controller
class WaitlistsController < ApplicationController
  before_action :set_waitlist, only: %i[edit update destroy]
  before_action :set_activity, only: %i[new edit]

  # GET /waitlists/new
  def new
    @waitlist = Waitlist.new
  end

  # GET /waitlists/1/edit
  def edit
    @user = @waitlist.user
  end

  # POST /waitlists or /waitlists.json
  def create
    phone = Phonelib.parse(waitlist_params[:phone]).national

    user = User.find_or_create_by!(name: waitlist_params[:name], surname: waitlist_params[:surname], phone:)
    @waitlist = Waitlist.build(user:, activity_id: waitlist_params[:activity_id])

    if @waitlist.save
      redirect_to activity_url(@waitlist.activity), notice: t('.create_succ')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /waitlists/1 or /waitlists/1.json
  def update
    phone = Phonelib.parse(waitlist_params[:phone]).national
    user = @waitlist.user

    if user.update(name: waitlist_params[:name], surname: waitlist_params[:surname], phone:)
      redirect_to waitlist_url(@waitlist), notice: t('.update_succ')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /waitlists/1 or /waitlists/1.json
  def destroy
    activity = @waitlist.activity
    @waitlist.destroy!

    redirect_to activity_path(activity), notice: t('.destroy_succ')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_waitlist
    @waitlist = Waitlist.find(params[:id])
  end

  def set_activity
    @activity = Activity.find(params[:activity_id])
  end

  # Only allow a list of trusted parameters through.
  def waitlist_params
    params.require(:waitlist).permit(:name, :surname, :phone, :activity_id)
  end
end
