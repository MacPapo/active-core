# frozen_string_literal: true

# Packages Controller
class PackagesController < ApplicationController
  include Filterable
  include Sortable

  before_action :authorize_admin!
  before_action :set_package, only: [ :edit, :update, :destroy ]

  def index
    @packages = Package.kept
                  .then { |packages| apply_filters(packages) }
                  .then { |packages| apply_sorting(packages) }
  end

  def show
    @package = Package.includes(package_inclusions: :product).kept.find(params[:id])
  end

  def new
    @package = Package.new
    @package.package_inclusions.build
    @available_products = Product.kept.active.where.not(product_type: "membership")
  end

  def create
    @package = Package.new(package_params)

    if @package.save
      redirect_to @package, notice: "Pacchetto creato con successo."
    else
      @available_products = Product.kept.active.where.not(product_type: "membership")
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @available_products = Product.kept.active.where.not(product_type: "membership")
  end

  def update
    if @package.update(package_params)
      redirect_to @package, notice: "Pacchetto aggiornato con successo."
    else
      @available_products = Product.kept.active.where.not(product_type: "membership")
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @package.discard
    redirect_to packages_path, notice: "Pacchetto eliminato con successo."
  end

  private

  def set_package
    @package = Package.kept.find(params[:id])
  end

  def package_params
    params.require(:package).permit(:name, :description, :price, :affiliated_price,
                                    :duration_type, :duration_value, :valid_from,
                                    :valid_until, :active, :max_sales,
                                    package_inclusions_attributes: [ :id, :product_id,
                                                                    :access_type, :session_limit, :notes, :_destroy ])
  end

  # Filterable
  def filterable_attributes
    {
      active: ->(scope, value) { scope.where(active: value) if value.present? }
    }
  end

  # Sortable
  def sortable_attributes
    { "name" => "packages.name", "price" => "packages.price" }
  end

  def default_sort
    { attribute: "name", direction: "asc" }
  end
end
