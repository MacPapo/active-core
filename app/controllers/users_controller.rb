# frozen_string_literal: true

# User Controller
class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]

  # GET /users
  def index
    @sort_by = params[:sort_by] || 'updated_at'
    @direction = params[:direction] || 'desc'

    # Filtri
    filters = {
      name: params[:name],
      membership_status: params[:membership_status],
      activity_status: params[:activity_status],
      activity_id: params[:activity_id],
      sort_by: @sort_by,
      direction: @direction
    }

    @pagy, @users = pagy(
      User.filter(filters)
        .includes(:membership, :subscriptions, :legal_guardian)
        .load_async
    )
  end

  def activity_search
    query = params[:query]
    if query.present?
      @users = User.joins(:membership).where('membership.status' => :active)

      query.split.each { |term| @users = @users.where('name LIKE ? OR surname LIKE ?', "%#{term}%", "%#{term}%") }
    else
      @users = User.none
    end

    respond_to { |f| f.json { render json: localize_activity_search_result(@users.select(:id, :name, :surname, :birth_day)) } }
  end

  # GET /users/1
  def show; end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @legal_guardian = @user.legal_guardian
  end

  # POST /users
  def create
    @user = User.new(extract_user_params(user_params))
    legal_guardian_params = params.dig(:user, :legal_guardian)
    @user.legal_guardian = find_or_create_this_lg(legal_guardian_params)

    if @user.save
      redirect_to new_membership_path(user_id: @user.id, staff_id: current_staff),
                  notice: t('.create_succ')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(extract_user_params(user_params))
      update_this_lg(@user, params.dig(:user, :legal_guardian))

      redirect_to user_url(@user), notice: t('.update_succ')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy!

    redirect_to users_url, notice: t('.destroy_succ')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  def find_or_create_this_lg(data)
    return nil if data.blank?

    LegalGuardian.find_or_create_by(email: data[:email]) do |lg|
      lg.email = data[:email]
      lg.name = data[:name]
      lg.surname = data[:surname]
      lg.phone = data[:phone]
      lg.birth_day = data[:birth_day]
    end
  end

  def update_this_lg(user, lg_params)
    return if lg_params.values.all?(&:empty?)

    lg = user.legal_guardian
    if lg.present?
      lg.update!(email: lg_params[:email], name: lg_params[:name],
                 surname: lg_params[:surname], phone: lg_params[:phone],
                 birth_day: lg_params[:birth_day])
    else
      user.legal_guardian = find_or_create_this_lg(lg_params)
      user.save
    end
  end

  def extract_user_params(params)
    params.except(:legal_guardian)
  end

  def localize_activity_search_result(res)
    res.map { |u| { id: u.id, name: u.name, surname: u.surname, birth_day: I18n.l(u.birth_day, formt: :short) } }
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(
      :cf, :name, :surname, :email, :phone, :birth_day, :med_cert_issue_date, :affiliated,
      legal_guardian: %i[email name surname phone birth_day]
    )
  end
end
