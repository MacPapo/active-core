# frozen_string_literal: true

# User Controller
class UsersController < ApplicationController
  include Filterable
  include Sortable

  before_action :authorize_admin!
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @users = User.kept
               .includes(:member)
               .then { |users| apply_filters(users) }
               .then { |users| apply_sorting(users) }
  end

  def show
    @user_stats = user_statistics
  end

  def new
    @user = User.new
    @available_members = available_staff_members
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: "Utente staff creato con successo."
    else
      @available_members = available_staff_members
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @available_members = available_staff_members
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: "Utente aggiornato con successo."
    else
      @available_members = available_staff_members
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @user.discard
    redirect_to users_path, notice: "Utente eliminato con successo."
  end

  private

  def set_user
    @user = User.kept.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:nickname, :member_id, :role,
                                 :password, :password_confirmation)
  end

  def available_staff_members
    Member.kept
      .left_joins(:user)
      .where(users: { id: nil })
      .order(:surname, :name)
  end

  def user_statistics
    {
      created_memberships: Membership.where(user: @user).count,
      processed_payments: Payment.where(user: @user).count,
      created_registrations: Registration.where(user: @user).count
    }
  end

  # Filterable concern methods
  def filterable_attributes
    {
      role: ->(scope, value) { scope.where(role: value) if value.present? },
      search: ->(scope, value) {
      scope.joins(:member)
        .where("members.name LIKE ? OR members.surname LIKE ? OR users.nickname LIKE ?",
          "%#{value}%", "%#{value}%", "%#{value}%") if value.present?
    }
    }
  end

  # Sortable concern methods
  def sortable_attributes
    {
      "name" => "members.name",
      "surname" => "members.surname",
      "nickname" => "users.nickname",
      "role" => "users.role",
      "created_at" => "users.created_at"
    }
  end

  def default_sort
    { attribute: "created_at", direction: "desc" }
  end
end
