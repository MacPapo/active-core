# frozen_string_literal: true

# Staff Controller
class StaffsController < ApplicationController
  before_action :set_staff, only: %i[show edit update destroy restore]
  before_action :set_roles, only: %i[new edit]

  # GET /staffs
  def index
    @sort_by = params[:sort_by] || 'updated_at'
    @direction = params[:direction] || 'desc'

    filters = {
      visibility: params[:visibility],
      name: params[:name],
      role: params[:staff_role],
      sort_by: @sort_by,
      direction: @direction
    }

    @pagy, @staffs = pagy(Staff.filter(filters).includes(:user).load_async)
  end

  # GET /staffs/1
  def show; end

  # GET /staffs/new
  def new
    @staff = Staff.build
  end

  # GET /staffs/1/edit
  def edit; end

  # POST /staffs
  def create
    @staff = Staff.new(staff_params)

    if @staff.save
      redirect_to staff_url(@staff), notice: t('.create_succ')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /staffs/1 or /staffs/1.json
  def update
    if @staff.update(staff_params)
      redirect_to staff_url(@staff), notice: t('.update_succ')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /staffs/1
  def destroy
    @staff.discard
    redirect_to staffs_url, notice: t('.destroy_succ')
  end

  # PATCH /staffs/1/restore
  def restore
    @staff.undiscard
    redirect_to staffs_url, notice: t('.restore_succ')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_staff
    @staff = Staff.find(params[:id])
  end

  def set_roles
    @roles = Staff.humanize_roles
  end

  # Only allow a list of trusted parameters through.
  def staff_params
    params.require(:staff).permit(:user_id, :nickname, :password, :role)
  end
end
