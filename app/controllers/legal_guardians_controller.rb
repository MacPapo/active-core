class LegalGuardiansController < ApplicationController
  before_action :set_legal_guardian, only: %i[ show edit update destroy ]

  # GET /legal_guardians or /legal_guardians.json
  def index
    @legal_guardians = LegalGuardian.all
  end

  # GET /legal_guardians/1 or /legal_guardians/1.json
  def show
  end

  # GET /legal_guardians/new
  def new
    @legal_guardian = LegalGuardian.new
  end

  # GET /legal_guardians/1/edit
  def edit
  end

  # POST /legal_guardians or /legal_guardians.json
  def create
    @legal_guardian = LegalGuardian.new(legal_guardian_params)

    respond_to do |format|
      if @legal_guardian.save
        format.html { redirect_to legal_guardian_url(@legal_guardian), notice: "Legal guardian was successfully created." }
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
        format.html { redirect_to legal_guardian_url(@legal_guardian), notice: "Legal guardian was successfully updated." }
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
      format.html { redirect_to legal_guardians_url, notice: "Legal guardian was successfully destroyed." }
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
      params.require(:legal_guardian).permit(:name, :surname, :email, :phone, :date_of_birth)
    end
end
