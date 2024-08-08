class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /users
  def index
    @pagy, @users = pagy(User.all)
  end

  # GET /users/1
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to new_membership_path(user_id: @user.id, staff_id: current_staff), notice: "L'utente è stato correttamente creato."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to user_url(@user), notice: "L'utente è stato correttamente aggiornato."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    # TODO fix problem with OPEN
    @user.destroy!

    redirect_to users_url, notice: "L'utente è stato correttamente eliminato."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:cf, :name, :surname, :email, :phone, :date_of_birth, :med_cert_issue_date, :affiliated, :legal_guardian_id)
  end
end
