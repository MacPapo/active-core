# frozen_string_literal: true

# Legal Guardian Controller
class LegalGuardiansController < ApplicationController
  before_action :set_legal_guardian, only: %i[show edit update destroy]

  # GET /legal_guardians or /legal_guardians.json
  def index
    @sort_by = params[:sort_by] || 'updated_at'
    @direction = params[:direction] || 'desc'

    @pagy, @legal_guardians = pagy(
      LegalGuardian.filter(params[:name], @sort_by, @direction)
        .includes(:users)
        .load_async
    )

    respond_to { |f| f.html }
  end

  # GET /legal_guardians/1 or /legal_guardians/1.json
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

  # POST /legal_guardians or /legal_guardians.json
  def create
    @legal_guardian = LegalGuardian.new(legal_guardian_params)

    respond_to do |format|
      if @legal_guardian.save
        format.html { redirect_to legal_guardian_url(@legal_guardian), notice: t('.create_succ') }
        format.json { render :show, status: :created, location: @legal_guardian }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @legal_guardian.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /legal_guardians/1 or /legal_guardians/1.json
  def update
    respond_to do |format|
      if @legal_guardian.update(legal_guardian_params)
        format.html { redirect_to legal_guardian_url(@legal_guardian), notice: t('.update_succ') }
        format.json { render :show, status: :ok, location: @legal_guardian }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @legal_guardian.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /legal_guardians/1 or /legal_guardians/1.json
  def destroy
    @legal_guardian.destroy!

    respond_to do |format|
      format.html { redirect_to legal_guardians_url, notice: t('.destroy_succ') }
      format.json { head :no_content }
    end
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
