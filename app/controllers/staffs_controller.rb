class StaffsController < ApplicationController
  before_action :set_staff, only: %i[ show edit update destroy ]
  before_action :set_roles, only: %i[ new edit ]

  # GET /staffs
  def index
    @pagy, @staffs = pagy(
      Staff
        .all
        .includes(:user)
    )
  end

  # GET /staffs/1
  def show
  end

  # GET /staffs/new
  def new
    @staff = Staff.build
  end

  # GET /staffs/1/edit
  def edit
  end

  # POST /staffs
  def create
    @staff = Staff.new(staff_params)

    if @staff.save
      redirect_to staff_url(@staff), notice: "Staff was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /staffs/1 or /staffs/1.json
  def update
    if @staff.update(staff_params)
      redirect_to staff_url(@staff), notice: "Staff was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /staffs/1 or /staffs/1.json
  def destroy
    @staff.destroy!

    redirect_to staffs_url, notice: "Staff was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_staff
      @staff = Staff.find(params[:id])
    end

    def set_roles
      @roles = Staff.roles.keys
    end

    # Only allow a list of trusted parameters through.
    def staff_params
      params.require(:staff).permit(:user_id, :nickname, :password, :role)
    end
end
