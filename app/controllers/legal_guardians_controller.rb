# frozen_string_literal: true

# Legal Guardian Controller
class LegalGuardiansController < ApplicationController
  before_action :set_legal_guardian, only: %i[show edit update destroy]

  # GET /legal_guardians or /legal_guardians.json
  def index
    @max = LegalGuardian.joins(:users).group(:legal_guardian_id).count.values.max || 0

    @sort_by = params[:sort_by] || 'updated_at'
    @direction = params[:direction] || 'desc'

    filters = {
      name: params[:name],
      range: params[:users_range],
      sort_by: @sort_by,
      direction: @direction
    }

    @pagy, @legal_guardians = pagy(
      LegalGuardian.filter(filters)
        .includes(:users)
        .load_async
    )
  end

  # GET /legal_guardians/1
  def show; end

  def find_by_email
    email = params[:email]
    legal_guardian = LegalGuardian.find_by(email:)

    if legal_guardian
      render json: { found: true, legal_guardian: }
    else
      render json: { found: false }
    end
  end

  # GET /legal_guardians/new
  def new
    @legal_guardian = LegalGuardian.new
  end

  # GET /legal_guardians/1/edit
  def edit; end

  # POST /legal_guardians
  def create
    @legal_guardian = LegalGuardian.new(legal_guardian_params)

    if @legal_guardian.save
      redirect_to legal_guardian_url(@legal_guardian), notice: t('.create_succ')
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /legal_guardians/1
  def update
    if @legal_guardian.update(legal_guardian_params)
      redirect_to legal_guardian_url(@legal_guardian), notice: t('.update_succ')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /legal_guardians/1
  def destroy
    @legal_guardian.discard
    redirect_to legal_guardians_url, notice: t('.destroy_succ')
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_legal_guardian
    @legal_guardian = LegalGuardian.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def legal_guardian_params
    params.require(:legal_guardian).permit(:name, :surname, :email, :phone, :birth_day)
  end
end
