# frozen_string_literal: true

# Memberships Controller
class MembershipsController < ApplicationController
  include Filterable
  include Sortable

  before_action :authorize_admin!, only: [ :index, :edit, :update ]
  before_action :authorize_internal_access!, only: [ :destroy ]

  before_action :set_membership, only: [ :edit, :update, :destroy ]
  before_action :set_member, only: [ :create, :destroy ], if: -> { params[:member_id] }

  def index
    @memberships = Membership.kept
                     .includes(:member, :pricing_plan)
                     .then { |memberships| apply_filters(memberships) }
                     .then { |memberships| apply_sorting(memberships) }
  end

  def create
    pricing_plan = PricingPlan.kept.active.find(membership_params[:pricing_plan_id])
    discounts = Discount.kept.active.where(id: membership_params[:discount_ids] || [])

    @membership = @member.create_or_renew_membership!(
      user: current_user,
      payment_method: membership_params[:payment_method],
      pricing_plan:,
      discounts:
    )

    if @membership&.persisted?
      redirect_to member_path(@member), notice: "Tesseramento creato o rinnovato con successo." # TODO localize
    else
      redirect_to member_path(@member), alert: @member.errors.full_messages.to_sentence
    end
  end

  def edit
    @available_pricing_plans = PricingPlan.kept.active
  end

  def update
    if @membership.update(membership_update_params)
      redirect_to memberships_path, notice: "Membership aggiornata." # TODO localize
    else
      @available_pricing_plans = PricingPlan.kept.active
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @membership.discard

    redirect_to @member, notice: "Membership cancellata."
  end

  private

  def set_member
    @member = Member.kept.find(params[:member_id])
  end

  def set_membership
    @membership = Membership.kept.find(params[:id])
  end

  def membership_params
    params.require(:membership).permit(:pricing_plan_id, :payment_method, discount_ids: [])
  end

  def membership_update_params
    params.require(:membership).permit(:status, :end_date)
  end

  def membership_statistics
    {
      days_remaining: (@membership.end_date - Date.current).to_i,
      total_registrations: @membership.member.registrations.count,
      active_registrations: @membership.member.registrations.where(status: :active).count,
      total_spent: calculate_member_revenue
    }
  end

  def calculate_member_revenue
    @membership.member.total_revenue
  end

  # Filterable methods
  def filterable_attributes
    {
      search: ->(scope, value) { scope.joins(:member).merge(Member.search_by_name(value)) if value.present? },
      status: ->(scope, value) { scope.where(status: value) if value.present? },
      expiring_soon: ->(scope, value) { scope.where(end_date: ..30.days.from_now) if value == "true" }
    }
  end

  # Sortable methods
  def sortable_attributes
    {
      "member_name" => "members.surname",
      "end_date" => "memberships.end_date",
      "status" => "memberships.status",
      "created_at" => "memberships.created_at"
    }
  end

  def default_sort
    { attribute: "end_date", direction: "asc" }
  end
end
