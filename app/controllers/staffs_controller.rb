# frozen_string_literal: true

# Staff Controller
class StaffsController < ApplicationController
  before_action :set_staff, only: %i[show edit update destroy restore]
  before_action :set_roles, only: %i[new edit]

  # GET /staffs
  def index
    @sort_by = params[:sort_by] || "updated_at"
    @direction = params[:direction] || "desc"

    filters = {
      visibility: params[:visibility],
      name: params[:name],
      role: params[:staff_role],
      sort_by: @sort_by,
      direction: @direction
    }

    @pagy, @staffs = pagy(User.filter(filters).includes(:user).load_async)
  end

  # GET /staffs/1
  def show; end

  # GET /staffs/new
  def new
    @staff = User.new
    @staff.build_user
  end

  # GET /staffs/1/edit
  def edit; end

  # POST /staffs
  def create
    if params[:staff][:user_id].present?
      @user = Member.find(params[:staff].delete(:user_id))
    else
      @user = Member.new(user_params)
      unless @user.save
        @staff = User.new(staff_params)
        @staff.errors.add(:base, "Impossibile creare l’utente: #{@user.errors.full_messages.join(', ')}")
        set_roles
        return render :new, status: :unprocessable_entity
      end
    end

    @staff = User.new(staff_params)
    @staff.user = @user
    @staff.role = params[:staff][:role] if current_staff.admin?

    if @staff.save
      redirect_to staff_url(@staff), notice: t(".create_succ")
    else
      set_roles
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /staffs/1 or /staffs/1.json
  def update
    if @staff.update(staff_params)
      redirect_to staff_url(@staff), notice: t(".update_succ")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /staffs/1
  def destroy
    @staff.discard
    redirect_to staffs_url, notice: t(".destroy_succ")
  end

  # PATCH /staffs/1/restore
  def restore
    @staff.undiscard
    redirect_to staffs_url, notice: t(".restore_succ")
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_staff
    @staff = User.find(params[:id])
  end

  def set_roles
    @roles = User.humanize_roles
  end

  def user_params
    params.require(:staff).require(:user).permit(:email, :phone, :name, :surname)
  end

  # Only allow a list of trusted parameters through.
  def staff_params
    attrs = [ :nickname, :password, :password_confirmation ]
    attrs << :role if current_staff.admin?
    params.require(:staff).permit(attrs)
  end
end
