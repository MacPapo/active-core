# app/controllers/memberships_controller.rb
class MembershipsController < ApplicationController
  include Filterable
  include Sortable

  before_action :authorize_admin!, only: [ :index, :edit, :update ]
  before_action :set_membership, only: [ :show, :edit, :update, :destroy ]
  before_action :set_member, only: [ :show, :create, :destroy ], if: -> { params[:member_id] }
  before_action :set_pricing_plan, only: [ :create ]

  def index
    @memberships = Membership.kept
                     .then { |memberships| apply_filters(memberships) }
                     .then { |memberships| apply_sorting(memberships) }
  end

  def show
    @membership_stats = membership_statistics
  end

  def create
    @membership = @member.create_or_renew_membership!(
      pricing_plan: @pricing_plan,
      payment_method: membership_params[:payment_method],
      user: current_user
    )

    redirect_to @member, notice: "Membership rinnovata con successo!"
  rescue StandardError => e
    redirect_to @member, alert: "Errore nel rinnovo: #{e.message}"
  end

  def edit
    @available_pricing_plans = PricingPlan.kept.active
  end

  def update
    if @membership.update(membership_update_params)
      redirect_to @membership, notice: "Membership aggiornata."
    else
      @available_pricing_plans = PricingPlan.active
      render :edit, status: :unprocessable_entity
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

  def set_pricing_plan
    id = params.dig(:membership, :pricing_plan_id)
    @pricing_plan = PricingPlan.kept.find(id)
  end

  def membership_params
    params.require(:membership).permit(:pricing_plan_id, :payment_method, :user)
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
