class AccessGrantsController < ApplicationController
  before_action :set_access_grant, only: %i[ show edit update destroy ]

  # GET /access_grants or /access_grants.json
  def index
    @access_grants = AccessGrant.all
  end

  # GET /access_grants/1 or /access_grants/1.json
  def show
  end

  # GET /access_grants/new
  def new
    @access_grant = AccessGrant.new
  end

  # GET /access_grants/1/edit
  def edit
  end

  # POST /access_grants or /access_grants.json
  def create
    @access_grant = AccessGrant.new(access_grant_params)

    respond_to do |format|
      if @access_grant.save
        format.html { redirect_to @access_grant, notice: "Access grant was successfully created." }
        format.json { render :show, status: :created, location: @access_grant }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @access_grant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /access_grants/1 or /access_grants/1.json
  def update
    respond_to do |format|
      if @access_grant.update(access_grant_params)
        format.html { redirect_to @access_grant, notice: "Access grant was successfully updated." }
        format.json { render :show, status: :ok, location: @access_grant }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @access_grant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /access_grants/1 or /access_grants/1.json
  def destroy
    @access_grant.destroy!

    respond_to do |format|
      format.html { redirect_to access_grants_path, status: :see_other, notice: "Access grant was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_access_grant
      @access_grant = AccessGrant.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def access_grant_params
      params.fetch(:access_grant, {})
    end
end
