class MembersController < ApplicationController
  before_action :set_member, only: %i[edit update destroy]

  def index
    @members = Member.kept.order(:last_name, :first_name)
  end

  def new
    @member = Member.new
  end

  def edit
  end

  def create
    @member = Member.new(member_params)
    if @member.save
      flash.now[:notice] = "Membro creato con successo."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @member.update(member_params)
      flash.now[:notice] = "Membro aggiornato con successo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @member.discard

    flash.now[:notice] = "Membro archiviato con successo."
  end

  private
    def set_member
      @member = Member.find(params[:id])
    end

    def member_params
      # Assicurati di includere tutti i campi del tuo form
      params.require(:member).permit(
        :first_name, :last_name, :birth_date, :tax_code, :email, :phone,
        :address, :city, :province, :zip_code,
        :medical_certificate_issued_on, :affiliated, :legal_guardian_id
      )
    end
end
