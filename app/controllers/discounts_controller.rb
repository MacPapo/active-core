class DiscountsController < ApplicationController
  include Filterable
  include Sortable

  before_action :authorize_admin!
  before_action :set_discount, only: [ :show, :edit, :update, :destroy ]

  def index
    @discounts = Discount.kept
                   .then { |discounts| apply_filters(discounts) }
                   .then { |discounts| apply_sorting(discounts) }
  end

  def show; end

  def new
    @discount = Discount.new
  end

  def create
    @discount = Discount.new(discount_params)

    if @discount.save
      redirect_to @discount, notice: "Sconto creato con successo."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @discount.update(discount_params)
      redirect_to @discount, notice: "Sconto aggiornato con successo."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @discount.discard
    redirect_to discounts_path, notice: "Sconto eliminato con successo."
  end

  private

  def set_discount
    @discount = Discount.kept.find(params[:id])
  end

  def discount_params
    params.require(:discount).permit(:name, :discount_type, :value, :max_amount,
                                     :valid_from, :valid_until, :stackable,
                                     :applicable_to, :active)
  end

  # Filterable
  def filterable_attributes
    {
      active: ->(scope, value) { scope.where(active: value) if value.present? },
      discount_type: ->(scope, value) { scope.by_type(value) },
      applicable_to: ->(scope, value) { scope.by_applicable_to(value) }
    }
  end

  # Sortable
  def sortable_attributes
    { "name" => "discounts.name", "value" => "discounts.value", "created_at" => "discounts.created_at" }
  end

  def default_sort
    { attribute: "name", direction: "asc" }
  end
end
