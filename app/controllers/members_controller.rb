# frozen_string_literal: true

# Member Controller
class MembersController < ApplicationController
  include Filterable
  include Sortable

  before_action :authorize_internal_access!
  before_action :set_member, only: [ :show, :edit, :update, :destroy ]

  def index
    @members = Member.kept
                 .then { |members| apply_filters(members) }
                 .then { |members| apply_sorting(members) }
  end

  def show
    @member_stats = member_statistics
  end

  def new
    @member = Member.new
    load_form_data
  end

  def create
    pricing_plan = PricingPlan.kept.active.find_by(membership_params[:pricing_plan_id])

    unless pricing_plan
      @member = Member.new(member_params)
      @member.errors.add(:base, "Devi selezionare un piano di tesseramento valido.")
      load_form_data
      render :new, status: :unprocessable_entity
      return # Interrompiamo l'esecuzione
    end

    discounts = Discount.kept.active.where(id: membership_params[:discount_ids] || [])
    membership_attrs = {
      user: current_user,
      payment_method: membership_params[:payment_method],
      pricing_plan:,
      discounts:
    }

    @member = Member.onboard!(member_attrs: member_params, membership_attrs:)
    if @member&.persisted?
      redirect_to member_path(@member), notice: "Membro registrato e iscritto con successo!" # TODO localize
    else
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @available_pricing_plans = PricingPlan.active.includes(:product)
  end

  def update
    if @member.update(member_params)
      redirect_to @member, notice: "Membro aggiornato con successo."
    else
      @available_pricing_plans = PricingPlan.active.includes(:product)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @member.discard

    redirect_to member_path(@member), notice: "Membro eliminato con successo."
  end

  private

  def set_member
    @member = Member.kept.find(params[:id])
  end

  def member_params
    params.require(:member).permit(:name, :surname, :email, :phone, :birth_day, :cf, :affiliated)
  end

  def membership_params
    params.permit(:pricing_plan_id, :payment_method, :discount_ids)
  end

  def load_form_data
    @available_pricing_plans = PricingPlan.active.for_memberships # Assicurati di avere questo scope
  end

  def member_statistics
    member_payments = Payment.joins(:payment_items)
                        .where(payment_items: { payable_type: "Membership", payable_id: @member.memberships.select(:id) })
                        .or(Payment.joins(:payment_items)
                              .where(payment_items: { payable_type: "Registration", payable_id: @member.registrations.select(:id) }))
                        .or(Payment.joins(:payment_items)
                              .where(payment_items: { payable_type: "PackagePurchase", payable_id: @member.package_purchases.select(:id) }))
    {
      total_memberships: @member.memberships.count,
      active_registrations: @member.registrations.where(status: :active).count,
      total_payments: member_payments.count
    }
  end

  # Filterable methods
  def filterable_attributes
    {
      search: ->(scope, value) {
      scope.search_by_name(value) if value.present?
    },
      membership_status: ->(scope, value) {
      case value
      when "active"
        scope.with_active_membership
      when "expired"
        scope.joins(:memberships).where.not(id: Member.with_active_membership.select(:id))
      when "none"
        scope.left_joins(:memberships).where(memberships: { id: nil })
      end
    },
      affiliated: ->(scope, value) {
      scope.where(affiliated: value) if value.present?
    }
    }
  end

  # Sortable methods
  def sortable_attributes
    {
      "name" => "members.name",
      "surname" => "members.surname",
      "email" => "members.email",
      "birth_day" => "members.birth_day",
      "created_at" => "members.created_at"
    }
  end

  def default_sort
    { attribute: "surname", direction: "asc" }
  end
end

# class MembersController < ApplicationController
#   before_action :set_member, only: [ :show, :edit, :update, :destroy ]

#   def index
#     @members = Member.kept
#                  .includes(:legal_guardian, :active_memberships, :active_registrations)
#                  .order(:surname, :name)

#     @members = @members.where("name LIKE ? OR surname LIKE ? OR email LIKE ?",
#                               "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
#     @members = @members.affiliated if params[:affiliated] == "true"
#     @members = @members.unaffiliated if params[:affiliated] == "false"
#   end

#   def show
#     @active_memberships = @member.active_memberships.includes(:pricing_plan)
#     @active_registrations = @member.active_registrations.includes(:product)
#     @recent_payments = PaymentItem.joins(:payment)
#                          .for_member(@member)
#                          .includes(:payment)
#                          .order(created_at: :desc)
#                          .limit(5)
#   end

#   def new
#     @member = Member.new
#     @legal_guardians = LegalGuardian.all.order(:surname, :name)
#   end

#   def create
#     @member = Member.new(member_params)

#     if @member.save
#       redirect_to @member, notice: "Membro creato con successo."
#     else
#       @legal_guardians = LegalGuardian.all.order(:surname, :name)
#       render :new, status: :unprocessable_entity
#     end
#   end

#   def edit
#     @legal_guardians = LegalGuardian.all.order(:surname, :name)
#   end

#   def update
#     if @member.update(member_params)
#       redirect_to @member, notice: "Membro aggiornato con successo."
#     else
#       @legal_guardians = LegalGuardian.all.order(:surname, :name)
#       render :edit, status: :unprocessable_entity
#     end
#   end

#   def destroy
#     @member.discard
#     redirect_to members_path, notice: "Membro eliminato con successo."
#   end

#   private

#   def set_member
#     @member = Member.kept.find(params[:id])
#   end

#   def member_params
#     params.require(:member).permit(:cf, :name, :surname, :email, :phone,
#                                    :birth_day, :med_cert_issue_date,
#                                    :affiliated, :legal_guardian_id)
#   end
# end
