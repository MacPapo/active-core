# frozen_string_literal: true

# Registrations Controller
class RegistrationsController < ApplicationController
  include Filterable
  include Sortable

  before_action :authorize_admin!, only: [ :index, :edit, :update ]
  before_action :authorize_internal_access!, only: [ :destroy ]

  before_action :set_member, only: [ :create, :destroy ], if: -> { params[:member_id] }
  before_action :set_registration, only: [ :edit, :update, :destroy ]

  def index
    @registrations = Registration.kept
                       .then { |registrations| apply_filters(registrations) }
                       .then { |registrations| apply_sorting(registrations) }
  end

  def create
    product = Product.find_by(id: registration_params[:product_id])
    pricing_plan = PricingPlan.find_by(id: registration_params[:pricing_plan_id])
    package = Package.find_by(id: registration_params[:package_id])
    discounts = Discount.where(id: registration_params[:discount_ids])

    if package.nil? && (product.nil? || pricing_plan.nil?)
      redirect_to member_path(@member), alert: "Prodotto o piano tariffario selezionato non valido." # TODO localize
      return
    end

    @registration = @member.create_or_renew_registration!(
      user: current_user,
      payment_method: registration_params[:payment_method],
      product:,
      pricing_plan:,
      package:,
      discounts:
    )

    if @registration&.persisted?
      redirect_to member_path(@member), notice: "Iscrizione creata con successo." # TODO localize
    else
      redirect_to member_path(@member), alert: @member.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @registration.update(registration_update_params)
      redirect_to registrations_path, notice: "Registrazione aggiornata."  # TODO localize
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @registration.discard

    redirect_to member_path(@member), notice: "Registrazione cancellata."
  end

  private

  def set_member
    @member = Member.kept.find(params[:member_id])
  end

  def set_registration
    @registration = Registration.kept.find(params[:id])
  end

  def registration_params
    params.require(:registration).permit(:product_id, :pricing_plan_id, :package_id, :payment_method, discount_ids: [])
  end

  def registration_update_params
    params.require(:registration).permit(:status, :sessions_remaining, :end_date)
  end

  def filterable_attributes
    {
      search: ->(scope, value) {
      scope.joins(:member, :product)
        .where("members.name LIKE ? OR members.surname LIKE ? OR products.name LIKE ?",
          "%#{value}%", "%#{value}%", "%#{value}%") if value.present?
    },
      status: ->(scope, value) { scope.where(status: value) if value.present? },
      product_type: ->(scope, value) {
      scope.joins(:product).where(products: { product_type: value }) if value.present?
    }
    }
  end

  def sortable_attributes
    {
      "member_name" => "members.surname",
      "product_name" => "products.name",
      "end_date" => "registrations.end_date",
      "status" => "registrations.status",
      "created_at" => "registrations.created_at"
    }
  end

  def default_sort
    { attribute: "created_at", direction: "desc" }
  end
end
