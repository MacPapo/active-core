# frozen_string_literal: true

# Products Controller
class ProductsController < ApplicationController
  include Filterable
  include Sortable

  before_action :authorize_admin!, except: [ :index, :show ]
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]

  def index
    @products = Product.kept
                  .then { |products| apply_filters(products) }
                  .then { |products| apply_sorting(products) }
  end

  def show
    @product_stats = product_statistics
  end

  def new
    @product = Product.new
    @product.pricing_plans.build
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to @product, notice: "Prodotto creato con successo!"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: "Prodotto aggiornato con successo."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @product.discard
    redirect_to products_path, notice: "Prodotto eliminato con successo."
  end

  private

  def set_product
    @product = Product.kept.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name, :product_type, :description, :capacity, :requires_membership, :active,
      pricing_plans_attributes: [
        :duration_type, :duration_value, :price, :affiliated_price,
        :valid_from, :valid_until, :active, :_destroy
      ]
    )
  end

  def product_statistics
    {
      total_registrations: @product.registrations.count,
      active_registrations: @product.active_registrations.count,
      current_utilization: @product.utilization_percentage,
      total_revenue: calculate_product_revenue
    }
  end

  def calculate_product_revenue
    @product.total_revenue
  end

  # Filterable methods
  def filterable_attributes
    {
      search: ->(scope, value) { scope.search_by_name(value) },
      product_type: ->(scope, value) { scope.by_type(value) },
      requires_membership: ->(scope, value) { value == "true" ? scope.membership_required : scope.open_access }
    }
  end

  # Sortable methods
  def sortable_attributes
    {
      "name" => "products.name",
      "product_type" => "products.product_type",
      "capacity" => "products.capacity",
      "created_at" => "products.created_at"
    }
  end

  def default_sort
    { attribute: "name", direction: "asc" }
  end
end
